module Ast
  class Token
    attr_accessor :type, :value
    
    def initialize(type, value)
      @type = type.to_sym
      @value = value
    end
    
    # Check whether an array given is valid, ie. it has a symbol
    # then one or no objects only.
    #
    # @param [Array, Token] arr
    # @example
    #
    #   Ast::Token.valid? [:type, 'val'] #=> true
    #   Ast::Token.valid? ['wrong', 'val'] #=> false
    #   Ast::Token.valid? ['too', 'long', 1] #=> false
    #   Ast::Token.valid? [:single] #=> true
    #
    def self.valid?(arr)
      if arr.is_a? Array
        if arr.nil? || arr.size > 2 || arr.size == 0
          return false
        elsif !arr[0].is_a?(Symbol)
          return false
        else
          return true
        end
      elsif arr.is_a? Token
        return true
      else
        return false
      end
    end
    
    # Make it print like a String
    def to_s
      if @value.nil?
        "[:#{type}]"
      else
        "[:#{type}, #{value.inspect}]"
      end
    end
    
    # @return [Array] token as an array
    def to_a
      if @value.nil?
        [@type]
      else
        [@type, @value]
      end
    end
    
    # Make #inspect show something a bit prettier
    def inspect
      self.to_s
    end
  
  end


  class Tokens < Array    
    # Remember the previous position
    attr_accessor :prev_pos
  
    class Error < StandardError; end
    
    # Creates tokens for each item given if not already and sets 
    # pointer.
    def initialize(args=[])
      @pos = 0
      return self if args == []
      if args[0].is_a? Token
        args.each_token do |i|
          self << i
        end
      else
        args.each do |i|
          if i.size > 0
            self << Token.new(i[0], i[1])
          else
            self << Token.new(i[0], nil)
          end
        end
      end
      self
    end
    
    # Converts the item given to a Token if an Array, then adds normally.
    def <<(val)
      raise "value given #{val} is invalid" unless Token.valid?(val)
      if val.is_a? Array
        if val.size > 0
          self << Token.new(val[0], val[1])
        else
          self << Token.new(val[0], nil)
        end
      else
        super
      end
    end
    
    # @return [Array] tokens as an array
    def to_a
      self.collect {|i| i.to_a }
    end
    
    # @group Scanning Tokens
      
      # @return [Token] the current token being 'pointed' to
      def pointer
        self[@pos]
      end
      
      # @return [Integer] current position
      def pos
        @pos
      end
      
      # Set the pointer position
      def pos=(val)
        @pos = val
      end
      
      # Gets a array of tokens +len+ from current position, without
      # advancing pointer
      #
      # @return [Array]
      def peek(len)
        self[self.pos..(self.pos+len)]
      end
      
      # Reads the next token along. If a type is given will throw error
      # if next token is of a different type.
      #
      # @param [Symbol] type
      # @return [Token]
      # @raise [Error] if type of next token does not match +type+
      #
      def scan(type=nil)
        @prev_pos = self.pos
        a = nil
        if type.nil?
          a = self.pointer
        else
          if self.pointer.type == type
            a = self.pointer
          else
            raise Error, "wrong type: #{type} for #{self.pointer}"
          end
        end
        self.pos += 1
        a
      end
      
      # Same as #scan but does not advance pointer
      def check(type=nil)
        if type.nil?
          self.pointer
        else
          if self.pointer.type == type
            self.pointer
          else
            raise Error, "wrong type: #{type} for #{self.pointer}"
          end
        end
      end
      
      # Attempts to skip the next token. If type is given will only skip
      # a token of that type, will raise error for anything else.
      #
      # @param [Symbol] type
      # @return [Integer] the new pointer position
      # @raise [Error] if type of next token does not match +type+
      #
      def skip(type=nil)
        @prev_pos = self.pos
        if type.nil?
          self.pos += 1
        else
          if self.pointer.type == type
            self.pos += 1
          else
            raise Error, "wrong type: #{type} for #{self.pointer}"
          end
        end
      end
      
      # @return [boolean] whether at end of tokens
      def eot?
        self.pos >= self.size
      end
      
      # Scans the tokens until a token of +type+ is found. Returns array
      # of tokens upto and including the matched token.
      #
      # @param [Symbol] type
      # @return [Array]
      #
      def scan_until(type)
        @prev_pos = self.pos
        r = []
        while self.pointer.type != type && !self.eot?
          r << self.scan
        end
        r
      end
      
      # Same as #scan_until but does not advance pointer
      def check_until(type)
        r = []
        a = 0
        while self.pointer.type != type && !self.eot?
          r << self.scan
          a += 1
        end
        self.pos -= a
        r
      end
      
      # Advances the pointer until token of +type+ is found. Returns
      # number of tokens advanced, including the matching token.
      #
      # @param [Symbol] type
      # @return [Integer]
      #
      def skip_until(type)
        @prev_pos = self.pos
        r = 0
        while self.pointer.type != type && !self.eot?
          self.pos += 1
          r += 1
        end
        r
      end
      
      # @return [Array] all tokens after the current token
      def rest
        self[self.pos..self.size]
      end
      
      # Set the scan pointer to the end of the tokens
      def clear
        self.pos = self.size
      end
      
      # Sets the pointer to the previous remembered position. Only one
      # previous position is remembered, which is updated every scan or
      # skip.
      def unscan
        if @prev_pos
          self.pos = @prev_pos
          @prev_pos = nil
        end
      end
      alias_method :unskip, :unscan
    
    # @endgroup
    
    # @group Enumeration
    
      alias_method :_each, :each
      # Loops through the types and contents of each tag separately, passing them
      # to the block given.
      #
      # @return [Ast::Tokens] returns self
      # @yield [Symbol, Object] gives the type and content of each block in turn
      #
      # @example
      #  
      #   tokens = Ast::Tokens.new
      #   tokens << [:a, 1] << [:b, 2] << [:c, 3] << [:d, 4]
      #
      #   sa.each do |t, v|
      #     puts "#{t} -> #{v}"
      #   end
      #   #=> a -> 1
      #   #=> b -> 2
      #   #=> c -> 3
      #   #=> d -> 4
      #  
      def each(&blck)
        self._each do |i|
          yield(i.type, i.value)
        end
        self
      end
      
      # Evalute block given for the type of each token
      # @see #each
      def each_type(&blck)
        self._each do |i|
          yield(i.type)
        end
      end
      
      # Evaluate block given for the value of each token
      # @see each
      def each_value(&blck)
        self._each do |i|
          yield(i.value)
        end
      end
      
      # Evaluate block given for each token instance
      # @see each
      def each_token(&blck)
        self._each do |i|
          yield(i)
        end
      end
    
    # @endgroup
    
  end
end