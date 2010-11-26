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
    
    # Make it print like a String
    def to_s
      if @value.nil?
        "[:#{@type}]"
      else
        "[:#{@type}, #{@value.inspect}]"
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
      "<#{self.to_s[1..-2]}>"
    end
  
  end
  
end