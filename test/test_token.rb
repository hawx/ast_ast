require File.join(File.dirname(__FILE__) ,'helper')

class TestToken < Test::Unit::TestCase

  context "A new Token" do
    setup { @token = Ast::Token.new(:test, 'value') }
    
    should "have a type" do
      assert_equal :test, @token.type
    end
    
    should "have a value" do
      assert_equal 'value', @token.value
    end
    
    should "print like Array" do
      assert_equal "[:test, \"value\"]", @token.to_s
    end
    
    should "turn into an Array" do
      assert_equal [:test, 'value'], @token.to_a
    end
  end


  context "Testing validaty of input" do
  
    should "accept array with one symbol" do
      assert Ast::Token.valid? [:test]
    end
    
    should "accept array with symbol then object" do
      o = Object.new
      assert Ast::Token.valid? [:test, o]
    end
    
    should "not accept array with size greater than two" do
      assert_false Ast::Token.valid? [:test, 2, 'three']
    end
  
    should "not accept array where first item is not a Symbol" do
      assert_false Ast::Token.valid? ['test', :fail]
    end
    
    should "not accept empty array" do
      assert_false Ast::Token.valid? []
    end
    
    should "accept Token instance" do
      assert Ast::Token.valid?(Ast::Token.new(:test, nil))
    end
    
    should "accept only Array or Token instances" do
      assert_false Ast::Token.valid? Object.new
      assert_false Ast::Token.valid? "string"
      assert_false Ast::Token.valid? 123
      assert_false Ast::Token.valid?({:hash => false})
      assert_false Ast::Token.valid? false
    end
  end
end
