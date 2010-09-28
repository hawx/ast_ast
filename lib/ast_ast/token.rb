module Ast
  class Token
    attr_accessor :type, :value
    
    def initialize(type, value)
      @type = type.to_sym
      @value = value
    end
    
    # Check whether an array given is valid, ie. it has a symbol
    # then an object only.
    #
    # @example
    #
    #   Ast::Token.valid? [:type, 'val'] #=> true
    #   Ast::Token.valid? ['wrong', 'val'] #=> false
    #   Ast::Token.valid? ['too', 'long', 1] #=> false
    #
    def self.valid?(arr)
      if arr.is_a? Array
        if arr.nil? || arr.size != 2 
          return false
        elsif !arr[0].is_a?(Symbol)
          return false
        else
          return true
        end
      elsif arr.is_a? Ast::Token
        return true
      else
        return false
      end
    end
  end
end