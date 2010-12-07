# @abstract
module Ast
  class Tokeniser
    
    class Rule  
      attr_accessor :name, :regex, :proc
      
      # Creates a new Rule instance
      # 
      # @param name [Symbol]
      #   Name of the token to be created.
      # @param regex [Regexp] 
      #    Regular expression to be matched
      # @param proc [Proc]  
      #    Optional proc to be executed with match(es)
      #
      def initialize(name, regex, proc=nil, &block)
        @name = name
        @regex = regex
        @proc = proc || block
      end
      
      # Runs the block that was given using either, the full match if there
      # were no captures in the regex, or an array of the captures.
      #
      # If a String is returned, which will be the case most of the time, a
      # single token is created with the value that is returned. But if an 
      # Array is returned then multiple tokens will be created for each item 
      # in the Array. See the examples for a better explanation.
      #
      # @param [String] val the string that was matched to +@regex+
      # @return [String, Array]
      #
      # @example Single tokens created (returns String)
      #
      #   class Klass < Ast::Tokeniser
      #     rule(:word, /[a-z]+/) {|i| i.reverse}
      #   end
      #
      #   Klass.tokenise("backwards sdrawrof")
      #   #=> [[:word, "sdrawkcab"], [:word, "forwards"]]
      #
      # @example Multiple tokens created (returns Array)
      #
      #   class Klass < Ast::Tokeniser
      #     rule(:letter, /[a-z]+/) {|i| i.split('')}
      #   end
      #
      #   Klass.tokenise("split up")
      #   #=> [[:letter, "s"], [:letter, "p"], [:letter, "l"], [:letter, "i"], 
      #   #     [:letter, "t"], [:letter, "u"], [:letter, "p"]]
      #
      #
      def run(val)
        arr = val.match(@regex).to_a
        val = arr unless arr.empty?
        val = arr[0] if arr.size == 1
        val = arr[0] if arr[0] == arr[1] # this happens with /(a|b|c)/ regexs
        @proc.call val
      end
    end
    
    # Creates a new Rule and adds to the +@rules+ list.
    # @see Rule#initialize
    #
    # @param name [Symbol]
    # @param regex [Regexp]
    #
    def self.rule(name, regex, &block)
      @rules ||= []
      # make rules with same name overwrite first rule
      @rules.delete_if {|i| i.name == name}
      
      # Create default block which just returns a value
      block ||= Proc.new {|i| i}
      # Make sure to return a token
      proc = Proc.new {|_i| 
        block_result = block.call(_i)
        if block_result.is_a? Array
          r = []
          block_result.each do |j|
            r << Ast::Token.new(name, j)
          end
          r
        else
          Ast::Token.new(name, block_result) 
        end
      }
      @rules << Rule.new(name, regex, proc)
    end
    
    # @return [Array]
    #   Rules that have been defined.
    #
    def self.rules; @rules; end
    
    # Creates a new token rule, that is the block returns an Ast::Token instance.
    # 
    # @example
    #  
    #   keywords = ['def', 'next', 'while', 'end']
    #
    #   token /[a-z]+/ do |i|
    #     if keywords.include?(i)
    #       Ast::Token.new(:keyword, i)
    #     else
    #       Ast::Token.new(:word, i)
    #   end
    #
    # @param regex [Regexp]
    #
    def self.token(regex, &block)
      @rules ||= []
      @rules << Rule.new(nil, regex, block)
    end
    
    # Define a block to run when no match is found, as with +.token+ the block
    # should return a token instance. The block will only be passed a single 
    # character at a time.
    #
    # @example
    #
    #   missing do |i|
    #     Ast::Token.new(i, i)
    #   end
    #
    def self.missing(&block)
      @missing ||= block
    end
    
    # Takes the input and uses the rules that were created to scan it.
    #
    # @param [String] 
    #   Input string to scan.
    #
    # @return [Tokens]
    #
    def self.tokenise(input)
      @rules ||= []
      @scanner = StringScanner.new(input)
      
      result = Tokens.new
      until @scanner.eos?
        m = false # keep track of matches
        @rules.each do |i|
          a = @scanner.scan(i.regex)
          unless a.nil?
            m = true # match happened
            ran = i.run(a)
            # split array into separate tokens, *not* values
            if ran.is_a? Array
              #ran.each {|a| result << [i.name, a]}
              ran.each {|a| result << a }
            else
              #result << [i.name, ran]
              result << ran
            end
          end
        end
        unless m # if no match happened
          # obviously no rule matches this so invoke missing if it exists
          ch = @scanner.getch # this advances pointer as well
          if @missing
            result << @missing.call(ch)
          end
        end
      end
      result
    end

  end
end
