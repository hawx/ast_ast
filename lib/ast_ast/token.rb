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
        "[:#{type}, #{value}]"
      end
    end
    
    # Make #inspect show something a bit prettier
    def inspect
      self.to_s
    end
  
  end


  class Tokens < Array
    attr_accessor :pointer
    
    # Creates tokens for each item given if not already and sets 
    # pointer.
    def initialize(args)
      @pointer = 0
      
      args.each do |i|
        if i === Token
          self << i
        else
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
          self << Token.new(i[0], i[1])
        else
          self << Token.new(i[0], nil)
        end
      else
        super
      end
    end
    
    # Reads the next token along. If a type is given will throw error
    # if next token is of a different type.
    #
    # @param [Symbol] type
    # @return [Token]
    #
    def read_next(type=nil)
      @pointer += 1
      if type.nil?
        self[@pointer]
      else
        if self[@pointer].type == type
          self[@pointer]
        else
          raise "wrong type: #{type} for #{self[@pointer]}"
        end
      end
    end
    
    # Reads until the token of +type+.
    #
    # @param [Symbol] type
    # @return [Array]
    #
    def read_until(type)
      r = []
      while self[@pointer].type != type && @pointer < self.size
        r << self.read_next
      end
      r.pop
      @pointer -= 1
      r
    end
    
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