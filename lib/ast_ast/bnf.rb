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
      
      def initialize(name, args, klass)
        @name = name
        @rules = args
        @klass = klass
        p order
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
        else
          
        end
      end
      
      # A terminal defintion does not reference any other 
      # definitions. This is largely irrelevent as Ast::Tokeniser
      # should take care of this but it may be useful in some 
      # cases.
      #
      # @return [Boolean] whether contains just terminal elements
      def terminal?
        @rules.each do |r|
          return false unless r == Array
          r.each do |i|
            return false if i === Symbol
          end
        end
      end
    end
    
    # Set up a hook to store the subclasses name.
    def self.inherited(klass); @@klass = klass; end
    
    def self.define(name, *args)
      @defs ||= []
      @defs << Definition.new(name, args, @@klass)
    end
    
    def self.to_tree(tokens)
      i = 0
      while i < tokens.size
        c = tokens[i]
        
        @defs.each do |d|
          d.rules.each do |rule|
            case rule
            when Array # reads multiple tokens
              # get list of tokens to match rule
              list = tokens[i..rule.size-1]
              # go to next if list is not big enough
              next if list.size < rule.size
              res = []
              # go through each and check
              rule.each_with_index do |r, i|
                if r == list[i][0] # add if correct
                  res << list[i][1]
                end
              end
              # check all tokens where correct
              next if res.size != rule.size
              c[0] = d.name
              c[1] = res.join('')
              tokens.slice!(i+1, rule.size-1)
            
            when Symbol # terminal rule
              if c[0] == rule
                c[0] = d.name
                i -= 1 # check this token again
              end
            end
          end
        end

        i += 1
      end

      p tokens
    end
  
  end
end

class Test < Ast::BNF
  define "Number",  ["Number", :number], :number
  define "Word",    ["Word", :letter], :letter
  define "String",  [:quote, "Word", :quote]
end

tokens = [[:letter, 'a'], [:letter, 'b'], [:number, '5'], [:number, '9']]
Test.to_tree(tokens)