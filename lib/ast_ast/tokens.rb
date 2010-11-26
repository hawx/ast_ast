module Ast

  # An Array of Token instances basically, but with added methods
  # which add StringScanner type capabilities.
  class Tokens < Array
    attr_accessor :prev_pos, :pos
  
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
    
    def inspect
      "#< [#{@pos}] #{self.to_s[1..-2]} >"
    end
    
    # @group Scanning Tokens
      
      # @return [Token] the current token being 'pointed' to
      def pointer
        self[@pos]
      end
      alias_method :curr_item, :pointer
      
      def inc
        @pos += 1 unless eot?
      end
      
      def dec
        @pos -= 1 unless @pos == 0
      end
      
      # Checks whether the pointer is at a token with type +type+
      def pointing_at?(type)
        pointing_at == type
      end
      
      # @return [Symbol] type of token being pointed at
      def pointing_at
        pointer.type
      end
      
      # Gets a array of tokens +len+ from current position, without
      # advancing pointer.
      #
      # @return [Tokens]
      def peek(len)
        self[@pos..(@pos+len-1)]
      end
      
      # Reads the next token along. If a type is given will throw error
      # if next token is of a different type.
      #
      # @param [Symbol] type
      # @return [Token]
      # @raise [Error] if type of next token does not match +type+
      #
      def scan(type=nil)
        @prev_pos = @pos
        a = check(type)
        inc
        a
      end
      
      # Same as #scan but does not advance pointer
      def check(type=nil)
        if type.nil?
          pointer
        else
          if pointing_at?(type)
            pointer
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
        @prev_pos = @pos
        if type.nil?
          inc
        else
          if pointing_at?(type)
            inc
          else
            raise Error, "wrong type: #{type} for #{self.pointer}"
          end
        end
      end
      
      # @return [boolean] whether at end of tokens
      def eot?
        @pos >= self.size-1
      end
      
      # Scans the tokens until a token of +type+ is found. Returns array
      # of tokens upto and including the matched token.
      #
      # @param [Symbol] type
      # @return [Tokens]
      #
      def scan_until(type)
        @prev_pos = @pos
        r = Tokens.new
        until pointing_at?(type) || self.eot?
          r << scan
        end
        r << scan
        r
      end
      
      # Same as #scan_until but does not advance pointer
      def check_until(type)
        r = Tokens.new
        a = 0
        until pointing_at?(type) || self.eot?
          r << scan
          a += 1
        end
        r << scan
        @pos -= a + 1
        r
      end
      
      # Advances the pointer until token of +type+ is found.
      #
      # @param [Symbol] type
      # @return [Integer] number of tokens advanced, including match
      #
      def skip_until(type)
        @prev_pos = @pos
        r = 0
        until pointing_at?(type) || self.eot?
          inc
          r += 1
        end
        inc
        r += 1
        r
      end
      
      # @return [Tokens] all tokens after the current token
      def rest
        self[pos..-1]
      end
      
      # Set the scan pointer to the end of the tokens
      def clear
        @pos = self.size-1
      end
      
      # Sets the pointer to the previous remembered position. Only one
      # previous position is remembered, which is updated every scan or
      # skip.
      def unscan
        if @prev_pos
          @pos = @prev_pos
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