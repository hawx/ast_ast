require 'spec_helper'

describe Ast::Token do

  describe ".valid?" do
    subject { Ast::Token }
    
    it "returns false when given 3 item array" do
      subject.valid?([:a, 'b', 1]).should be_false
    end
    
    it "returns false when 1st item is not symbol" do
      subject.valid?(['a', 'b']).should be_false
    end
    
    it "returns false when given empty array" do
      subject.valid?([]).should be_false
    end
    
    it "returns true when given [symbol, object]" do
      subject.valid?([:a, 'b']).should be_true
    end
    
    it "returns true when given a Token" do
      subject.valid?(Ast::Token.new(:a, 'b')).should be_true
    end
  end
  
  
  context "when token has value" do
    subject { Ast::Token.new(:a, 'b') }
      
    describe "#to_s" do
      it "shows type and value" do
        subject.to_s.should == "[:a, \"b\"]"
      end
    end
    
    describe "#to_a" do
      it "returns array with type and value" do
        subject.to_a.should == [:a, 'b']
      end
    end
  end
    
  context "when token has no value" do
    subject { Ast::Token.new(:a, nil) }
    
    describe "#to_s" do
      it "shows only type" do
        subject.to_s.should == "[:a]"
      end
    end
    
    describe "#to_a" do
      it "returns array with only type" do
        subject.to_a.should == [:a]
      end
    end
  end

end