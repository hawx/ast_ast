require File.dirname(__FILE__) + '/token.rb'

module Ast
  class Ast
    attr_accessor :tokens, :token_descs, :groups
    
    # Describes what to do when a token is found
    class TokenDesc
      attr_accessor :name, :block
    
      def initialize(name, &block)
        @name = name
        @block = block
      end
    end
    
    # @see Ast::Ast#group
    class Group
      attr_accessor :name, :items
      
      def initialize(name, items)
        @name = name
        @items = items
      end
      
      # @see Array#include?
      def include?(arg)
        @items.include?(arg)
      end
    end
    
    # Creates a new token within the subclass. The block is executed
    # when the token is found during the execution of #astify.
    #
    # @example
    #
    #   class TestAst < Ast::Ast
    #     token :test do
    #       p 'test'
    #     end
    #   end
    #
    def self.token(name, &block)
      @token_descs ||= []
      @token_descs << TokenDesc.new(name, &block)
    end
    
    # Creates a new group of token types, this allows you to refer 
    # to multiple tokens easily
    #
    #  @example
    #
    #     group :names, [:john, :dave, :josh]
    #
    def self.group(name, items)
      @groups ||= []
      @groups << Group.new(name, items)
    end
    
    # Runs the +tokens+ through the list found created using #token.
    # Executes the block of the correct token using the token itself.
    # returns the created list.
    def self.astify(tokens)
      @tokens = tokens
      r = []
      @token_descs.each do |i|
        r << i.block.call(:help, 'method')
      end
      p r[0]
    end
    
    # Internal for #token block usage
    def self.read_next(type=nil)
      @tokens.read_next(type)
    end
    
    def self.read_until(type)
      @tokens.read_until(type)
    end
  
  end
end



<<EOS # sample code
class Simple
  def add(n1, n2)
    return n1 + n2
  end
end
EOS

<<EOS # the tokens
[:class], [:id, 'Simple'],
  [:def], [:id, 'add'], [:oparen], [:id, 'n1'], [:id, 'n2'], [:cparen],
    [:return], [:id, 'n1'], [:id, :+], [:id, 'n2'],
  [:end],
[:end]
EOS

<<EOS # above as AST
[:class,
 :Simple,
 [:const, :Object],
 [:defn,
  :add,
  [:scope,
   [:block,
    [:args, :n1, :n2],
    [:return, [:call, [:lvar, :n1],
               :+, [:array, [:lvar, :n2]]]]]]]]
EOS

class RubyAst < Ast::Ast
  # :class ... :end
  token :class do
    [:class, 
     read_next(:id).value.to_sym,
     [:const, :Object],
     read_until(:end)
    ]
  end
  
  token :defn do
    [:defn, 
     read_next(:id).value.to_sym,
     read_until(:end)
    ]
  end
end

code = Ast::Tokens.new([
[:class], [:id, 'Simple'],
  [:defn], [:id, 'add'], [:oparen], [:id, 'n1'], [:id, 'n2'], [:cparen],
    [:return], [:id, 'n1'], [:id, :+], [:id, 'n2'],
  [:end],
[:end]
])
RubyAst.astify(code)
