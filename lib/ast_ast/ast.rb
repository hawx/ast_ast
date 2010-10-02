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
      
      until @tokens.EOT?
        c = @tokens.read_next
        desc = @token_descs.find_all {|i| i.name == c.type}[0] if c
        r << desc.block.call(c) if desc
      end
      
      #@token_descs.each do |i|
      #  p i
      #  r << i.block.call(@tokens.current)
      #end
      r[0]
    end
    
    # Internal for #token block usage
    def self.read_next(type=nil)
      @tokens.read_next(type)
    end
    
    def self.scan_next(type=nil)
      @tokens.scan_next(type)
    end
    
    # @todo Get this to work properly
    #   The main problem is recurrsion, this _should_ allow someone
    #   to nest 'blocks' eg. [:begin], ..., [:begin], ..., [:end], [:end]
    #   should correctly find and execute the middle block, instead of
    #   getting stuck on the final [:end]. The way this will probably have 
    #   to be done is by passing the remaining tokens down to a new 
    #   'process' but with an end condition.
    #
    def self.read_until(type)
      t = @tokens.rest
      return if t.nil?
      # Need to process the rest separately so :ends are found in the 
      # correct order
      self.ancestors[0].astify Tokens.new(t)
    end
  
  end
end


=begin
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
     read_next(:id).value,
     [:const, :Object],
     read_until(:end)
    ]
  end
  
  # :defn ... :end
  token :defn do
    [:defn, 
     read_next(:id).value,
     [:scope, 
      [:block,
       (scan_next.type != :oparen ? p('hi') : nil),
       [:args], 
       read_until(:end)
      ]
     ]
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
p RubyAst.astify(code)
=end