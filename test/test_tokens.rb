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
    
    should "set pointer to 0" do
      assert_equal 0, @tokens.pointer
    end
    
    should "read next token" do
      assert_equal [:first], @tokens.read_next.to_a
    end
    
    should "raise error if next token is wrong type" do
      assert_raise StandardError do
        @tokens.read_next(:third)
      end
    end
  end

end
