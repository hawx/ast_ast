$: << File.dirname(__FILE__)
require 'token'

module Ast

  # Allows you to describe the tree using BNF style syntax.
  #
  # In normal BNF you would write something like:
  #
  #   <LETTER> ::= a|b|c|d|...|X|Y|Z
  #   <WORD>   ::= <WORD><LETTER>|<LETTER>
  #   <QUOTE>  ::= ' 
  #   <STRING> ::= <QUOTE><WORD><QUOTE>
  #
  # With Ast::BNF, assuming you have the correct tokens, it would
  # become:
  #
  #   define "Word",  ["Word", :letter], :letter
  #   define "String",  [:quote, "Word", :quote]
  #
  class BNF
    attr_accessor :tokens, :defs
  
    class Definition
      attr_accessor :name, :rules
      
      def initialize(name, rules, klass)
        @name = name
        @rules = rules.map {|i| i.is_a?(Array) ? i : [i] }
        @klass = klass
      end
      
      # Gets the order of the Definition, this does require
      # access to the other definitions. Here's why:
      #
      # The order of a definition is basically how many (max) 
      # times would you have to loop thorugh to get to a 
      # terminal rule. So from the example below,
      #
      #   <LETTER> ::= a|b|c|d|...|X|Y|Z       #=> terminal
      #   <WORD>   ::= <WORD><LETTER>|<LETTER> #=> 1st order
      #   <STRING> ::= '<WORD>'                #=> 2nd order
      #
      # Here it is easy to see that <LETTER> is terminal, no 
      # other rule will have to be looked at to determine if 
      # something is a <LETTER>. For a <WORD> you have to look
      # at the <LETTER> definition, so this is 1st order. And 
      # for <STRING>, you need to look at <WORD> which in turn
      # looks at <LETTER>, so you are going back 2 steps.
      #
      # @return [Integer] order of definition
      #
      def order
        if terminal?
          0
        elsif self_referential?
          1
        else
          r = 0
          @rules.each do |rule|
            # Only interested in rule with recursion
            if rule.size > 1
              rule.each do |elem|
                # Only interested in references
                if elem.is_a? String
                  b = @klass.defs.find_all {|i| i.name == elem}[0].order + 1
                  r = b if b > r # swap if higher
                end
              end
            end
          end
          r
        end
      end
      
      # A terminal defintion does not reference any other 
      # definitions. This is largely irrelevent as Ast::Tokeniser
      # should take care of this but it may be useful in some 
      # cases.
      #
      # @return [Boolean] whether contains just terminal elements
      #
      def terminal?
        @rules.each do |r|
          if r.is_a? Array
            r.each do |i|
             return false if i.is_a? String
            end
          end
        end
        true
      end
      
      # A Definition is self referential if the only refernce to
      # another rule is to itself or if the other references are
      # to terminal rule.
      #
      # This is not a perfect definition of what "self referential"
      # really means but it does help when finding the order!
      #
      # @return [Boolean] whether the definition is self referential 
      #
      def self_referential?
        r = false
        @rules.each do |rule|
          rule.each do |elem|
            if elem == @name
              r = true
            else
              k = @klass.defs.find_all{|i| i.name == elem}[0]
              if k && k.terminal?
                r = true
              else
                return false  
              end
            end
          end
        end
        r
      end
      
      def inspect; "#<Ast::BNF::Definition #{@name}>"; end
      
    end
    
    def initialize(name, &block)
      @block = block
    end
    
    def to_tree(tokens)
      self.instance_eval(&@block)
      
      # get matrix of defs in order by order
      defs_orders = @defs.collect {|i| [i.order, i]}
      ordered_defs = []
      defs_orders.each do |i|
        ordered_defs[i[0]] ||= []
        ordered_defs[i[0]] << i[1]
      end
        
      result = []
      ordered_defs.each do |order|
        
        order.each do |definition|
          c = tokens.scan
          
          definition.rules.each do |rule|
            list = tokens.peek(rule.size)
            
            res = []
            rule.zip(list) do |(a, b)|
              next if b.nil?
              if a == b.type
                res << b.value
              end
            end
            next if res.size != rule.size
            p [definition.name, res.join('')]
          end
        end
      end

      tokens
    end
    
    def define(name, *args)
      @defs ||= []
      @defs << Definition.new(name, args, self)
    end
    
  end
end


# This is here for testing only! Better name is required
def bnf_definition(name, &block)
  Ast::BNF.new(name, &block)
end

test = bnf_definition('hello') do
  define "Digit",   :number
  define "Letter",  :letter
  define "Number",  ["Number", "Digit"], "Digit"
  define "Word",    ["Word", "Letter"], "Letter"
  define "String",  [:quote, "Word", :quote]
end
p test.to_tree Ast::Tokens.new([[:letter, 'a'], [:letter, 'b'], [:number, '5'], [:number, '9']])
