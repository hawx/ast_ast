require File.join(File.dirname(__FILE__) ,'helper')

class TestTokens < Test::Unit::TestCase

  context "A new Tokens instance" do
    setup do
      @tokens = Ast::Tokens.new([[:first], [:second, 'value'], [:third, 3], [:final]])
    end
    
    should "be Array of Token instances" do
      @tokens.each_token do |t|
        assert_token t
      end
    end
    
    should "turn Tokens into Array" do
      res = [[:first], [:second, 'value'], [:third, 3], [:final]]
      assert_equal res, @tokens.to_a
    end
    
    should "convert Array to Token before adding" do
      @tokens << [:test]
      assert_contains @tokens.to_a, [:test]
    end
    
    should "add Token normally" do
      token = Ast::Token.new(:test, nil)
      @tokens << token
      assert_contains @tokens, token
    end
  
  end
  
  context "When scanning tokens" do
    setup do
      @tokens = Ast::Tokens.new([[:first], [:second, 'value'], [:third, 3], [:final]])
    end
    
    should "start with pointer at 0" do
      assert_equal 0, @tokens.pos
    end
    
    should "return current token" do
      assert_equal [:first], @tokens.pointer.to_a
    end
    
    # Single token operations
    should "scan next token, and advance pointer" do
      p = @tokens.pos
      assert_equal [:first], @tokens.scan.to_a
      assert_equal p+1, @tokens.pos
    end
    
    should "check next token, not advanicng pointer" do
      p = @tokens.pos
      assert_equal [:first], @tokens.check.to_a
      assert_equal p, @tokens.pos
    end
    
    should "skip next token by advancing pointer" do
      p = @tokens.pos
      assert_equal 1, @tokens.skip
      assert_equal p+1, @tokens.pos
    end
    
    should "raise error if next token is wrong type" do
      assert_raise Ast::Tokens::Error do
        @tokens.scan(:second)
      end
      assert_raise Ast::Tokens::Error do
        @tokens.check(:second)
      end
      assert_raise Ast::Tokens::Error do
        @tokens.skip(:second)
      end
    end
    
    # (x)_until operations
    should "scan until match, and advance pointer" do
      p = @tokens.pos
      assert_equal [[:first], [:second, "value"], [:third, 3]], @tokens.scan_until(:third)
      assert_equal p+3, @tokens.pos
    end
    
    should "check until match, not advancing pointer" do
      p = @tokens.pos
      assert_equal [[:first], [:second, "value"]], @tokens.check_until(:second)
      assert_equal p, @tokens.pos
    end
    
    should "skip until match by advancing pointer" do
      p = @tokens.pos
      assert_equal 4, @tokens.skip_until(:final)
    end
    
    # other methods
    should "get rest of tokens" do
      @tokens.pos = 2
      assert_equal [[:third, 3], [:final]], @tokens.rest
    end
    
    should "clear tokens" do
      @tokens.clear
      assert_equal @tokens.size, @tokens.pos
    end
    
    should "check whether at end of tokens" do
      assert_false @tokens.eot?
      @tokens.clear
      assert @tokens.eot?
    end
    
    should "get next n tokens" do
      @tokens.pos = 1
      assert_equal [[:second, "value"], [:third, 3]], @tokens.peek(2)
      assert_equal 1, @tokens.pos
    end
    
  end

end
