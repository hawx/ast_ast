module Ast
  class Ast
    attr_accessor :tokens, :token_descs, :block_descs, :groups
    
    # @see Ast::Ast#token
    class TokenDesc
      attr_accessor :name, :block
    
      def initialize(name, &block)
        @name = name
        @block = block || Proc.new {|t| t}
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
    
    # @see Ast::Ast#block
    class BlockDesc
      attr_accessor :open, :close, :block
      
      def initialize(open, close, &block)
        @open, @close = open, close
        @block = block || Proc.new {|b| b}
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
    # to multiple tokens easily.
    #
    # @example
    #
    #     group :names, [:john, :dave, :josh]
    #
    def self.group(name, items)
      @groups ||= []
      @groups << Group.new(name, items)
    end
    
    # Creates a block which begins with a certain token and ends with 
    # different token.
    #
    # @example
    #
    #     block :begin => :end do |r|
    #       ...
    #     end
    #
    def self.block(t, &block)
      @block_descs ||= []
      @block_descs << BlockDesc.new(t.keys[0], t.values[0], &block)
    end
    
    
    def self.astify(tokens)
      @tokens = tokens
      t = find_block
      t = run_tokens(t, @token_descs)
    end
    
    def self.run_tokens(tok, descs)
      r = []
      @curr_tree = tok
      
      until tok.eot?
        i = tok.scan
        case i
        when Token
          # run the token
          _desc = descs.find_all{|j| j.name == i.type}[0]
          if _desc
            r << _desc.block.call(i)
          else
            r << i
          end
        when Tree
          # run the whole branch
          r << run_tokens(i, descs)
        end
      end

      r
    end
    
    def self.find_block(curr_desc=nil)
      body = Tree.new
      
      until @tokens.eot?
        # Check if closes current search
        if curr_desc && curr_desc.close == @tokens.curr_item.type
          @tokens.inc
          return body
        
        # Check if close token in wrong place
        elsif @block_descs.map(&:close).include?(@tokens.curr_item.type)
          raise "close found before open: #{@tokens.curr_item}"
        
        # Check if open token
        elsif @block_descs.map(&:open).include?(@tokens.curr_item.type)
          _desc = @block_descs.find_all {|i| i.open == @tokens.curr_item.type }[0]
          @tokens.inc
          found = find_block(_desc)
          body << Tree.new(_desc.block.call(found))
        
        # Otherwise add to body, and start with next token
        else
          body << @tokens.curr_item
          @tokens.inc
        end
      end
      
      body
    end
    
    # @group For #token block
    
      # @see Tokens#scan
      def self.scan(type=nil)
        @curr_tree.scan(type)
      end
      
      # @see Tokens#check
      def self.check(type=nil)
        @curr_tree.check(type)
      end
      
      # @see Tokens#check
      def self.scan_until(type)
        @curr_tree.scan_until(type)
      end
      
      # @return [Ast::Tree] current tree being read
      def self.curr_tree
        @curr_tree
      end
  
  end
end
