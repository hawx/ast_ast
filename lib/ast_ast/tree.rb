module Ast
  # Trees are similar to tokens, in that they have a pointer but trees
  # are meant to be traversed. They can have branches (Trees within Tress).
  class Tree < Array
    attr_accessor :pos
    
    def initialize(*args)
      @pos = 0
      super
    end
    
    def inspect
      "{ #{self.to_s[1..-2]} }"
    end
    
    
    # @group Scanning/Checking/Skipping
    
      def inc
        @pos += 1 unless self.eot?
      end
      
      def dec
        @pos -= 1 unless @pos == 1
      end
      
      # @return [Token] the current token being 'pointed' to
      def pointer
        self[@pos]
      end
      alias_method :curr_item, :pointer
      
      # @return [boolean] whether at end of tokens
      def eot?
        self.pos >= self.size
      end
      
      def scan(type=nil)
        a = self.check(type)
        self.inc
        a
      end
      
      def rest
        self[@pos..-1]
      end
      
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
      
      def skip(type=nil)
        if type.nil?
          self.inc
        else
          if self.pointer.type == type
            self.inc
          else
            raise Error, "wrong type: #{type} for #{self.pointer}"
          end
        end
      end
    
  end
end