require File.dirname(__FILE__) + '/token.rb'

module Ast
  class Ast
    attr_accessor :tokens, :token_descs, :block_descs, :groups
    
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
    
    # @see Ast::Ast#block
    class BlockDesc
      attr_accessor :open, :close, :block
      
      def initialize(open, close, &block)
        @open, @close = open, close
        @block = block
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
    
    # Runs the +tokens+ through the list found created using #token.
    # Executes the block of the correct token using the token itself.
    # returns the created list.
    def self._astify(tokens)
      @tokens = tokens
      r = []
      
      blocks = []
      # First check if there are any block_descs
      if @block_descs
        # then run through these to find the actual blocks
        until @tokens.eot?
          c = @tokens.scan
          # check if a block is opened
          if @block_descs.map(&:open).include?(c.type)
            block_desc = @block_descs.find_all{|i| i.open == c.type }[0]
            body = []
            # check for block closing
            until @block_descs.map(&:close).include?(c.type)
              c = @tokens.scan
              body << c
            end
            body.pop # remove last element which is #close
            block_desc.body = body
          end
        end
      end
      
      # now we have the blocks we can run through token_descs
      
      # and return the final array
      
      
      #until @tokens.eot?
      #  c = @tokens.scan
      #  desc = @token_descs.find_all {|i| i.name == c.type}[0] if c
      #  r << desc.block.call(c) if desc
      #end
      
      #@token_descs.each do |i|
      #  p i
      #  r << i.block.call(@tokens.current)
      #end
      r[0]
    end
    
    def self.astify(tokens)
      tokens = find_block(tokens, @block_descs)
      tokens = run_tokens(tokens, @token_descs)
    end
    
    def self.run_tokens(tok, descs)
      r = []
      tok.each do |i|
        case i
        when Token
          _desc = descs.find_all{|j| j.name == i.type}[0]
          if _desc
            r << _desc.block.call(i)
          else
            r << i
          end
        when Array
          r << run_tokens(i, descs)
        end
      end
      r
    end
    
    def self.find_block(tok, descs, curr_desc=nil)
      body = []
      
      until tok.eot?
        if curr_desc && curr_desc.close == tok.curr_item.type
          tok.inc
          return body
          
        elsif descs.map(&:close).include?(tok.curr_item.type)
          raise "close found before open: #{tok.curr_item}"
        
        elsif descs.map(&:open).include?(tok.curr_item.type)
          _desc = descs.find_all{|i| i.open == tok.curr_item.type}[0]
          tok.inc
          found = find_block(tok, descs, _desc)
          body << _desc.block.call(found)
          
        else
          body << tok.curr_item
          tok.inc
        end
      end
      
      body
    end
    
    # Internal for #token block usage
    def self.scan(type=nil)
      @tokens.scan(type)
    end
    
    def self.check(type=nil)
      @tokens.check(type)
    end
    
    # @todo Get this to work properly
    #   The main problem is recurrsion, this _should_ allow someone
    #   to nest 'blocks' eg. [:begin], ..., [:begin], ..., [:end], [:end]
    #   should correctly find and execute the middle block, instead of
    #   getting stuck on the final [:end]. The way this will probably have 
    #   to be done is by passing the remaining tokens down to a new 
    #   'process' but with an end condition.
    #
    def self.scan_until(type)
      t = @tokens.rest
      return if t.nil?
      # Need to process the rest separately so :ends are found in the 
      # correct order
      self.ancestors[0].astify Tokens.new(t)
    end
  
  end
end



class BlockTest < Ast::Ast
  block :open => :close do |r|
    back = []
    r.each do |i|
      back << Ast::Token.new(i.type, "mod")
    end
    back
  end
  
  token :body do |t|
    t.value = "modified"
    t
  end
end

tokens = Ast::Tokens.new [[:body], [:open], [:body], [:another], [:close], [:body]]
puts BlockTest.astify(tokens).inspect