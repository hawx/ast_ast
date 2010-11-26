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
    # @param arr [Array, Token] 
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
          false
        elsif !arr[0].is_a?(Symbol)
          false
        else
          true
        end
      elsif arr.is_a? Token
        true
      else
        false
      end
    end
    
    # Turn the Token to a String, similar to an array.
    #
    # @example
    #
    #   Ast::Token.new(:test, "str").to_s
    #   #=> <:test "str">
    #
    # @return [String]
    #
    def to_s
      if @value.nil?
        "<:#{@type}>"
      else
        "<:#{@type}, #{@value.inspect}>"
      end
    end
    
    # Turn the Token to an Array.
    #
    # @example 
    #
    #   Ast::Token.new(:test, "str").to_a
    #   #=> [:test, "str"]
    #
    # @return [Array]
    #
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
  
end