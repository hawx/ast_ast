# @abstract
module Ast
  class Tokeniser
    attr_accessor :rules, :scanner
    
    # Describes a single rule created within the Ast::Tokeniser subclass
    class Rule  
      attr_accessor :name, :regex, :block
      
      # Creates a new Rule instance
      # 
      # @param [Symbol] name name of the token to be created
      # @param [Regexp] regex regular expression to be matched
      # @param [Proc] block optional block to be executed with match(es)
      def initialize(name, regex, &block)
        @name = name
        @regex = regex
        @block = block || Proc.new {|i| i}
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
      #   #=> [[:letter, "s"], [:letter, "p"], [:letter, "l"], [:letter, "i"], [:letter, "t"], [:letter, "u"], [:letter, "p"]]
      #
      #
      def run(val)
        arr = val.match(@regex).to_a
        val = arr unless arr.empty?
        val = arr[0] if arr.size == 1
        @block.call val
      end
    end
    
    # Creates a new Rule and adds to the +@rules+ list.
    # @see Ast::Tokeniser::Rule#initialize
    def self.rule(name, regex, &block)
      @rules ||= []
      # make rules with same name overwrite first rule
      @rules.delete_if {|i| i.name == name} 
      @rules << Rule.new(name, regex, &block)
    end
    
    # Takes the input and uses the rules that were created to scan it.
    #
    # @param [String] input string to scan
    # @return [Array]
    def self.tokenise(input)
      @scanner = StringScanner.new(input)
      
      result = []
      until @scanner.eos?
        @rules.each do |i|
          a = @scanner.scan(i.regex)
          unless a.nil?
            ran = i.run(a)
            # split array into separate tokens, *not* values
            if ran.is_a? Array
              ran.each {|a| result << [i.name, a]}
            else
              result << [i.name, ran]
            end
          end
        end
        # obviously no rule matches this so ignore it
        # could add verbose mode where this throws an exception!
        @scanner.pos += 1 unless @scanner.eos?
      end
      result
    end

  end
end
