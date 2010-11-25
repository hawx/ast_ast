require 'spec_helper'

describe Ast::Tokens do

  describe "#<<" do
    it "adds token to self" do
      token = Ast::Token.new(:a, 'b')
      subject << token
      subject.include?(token).should be_true
    end
    
    it "converts an array to a token and adds to self" do
      subject << [:a, 'b']
      subject.to_a.include?([:a, 'b']).should be_true
    end
  end
  
  describe "#to_a" do
    subject { Ast::Tokens.new([[:a, 'b'], [:c, 'd']]) }
    it "returns an array" do
      subject.to_a.should be_kind_of Array
    end
    
    it "contains arrays" do
      subject.to_a.each do |a|
        a.should be_kind_of Array
      end
    end
  end
  
  context "When scanning tokens" do
    subject {
      Ast::Tokens.new([[:a, 'b'], [:c, 'd'], [:e, 'f'], [:g, 'h'], [:i, 'j']])
    }
    
    
    describe "#pointer" do
      it "returns current token" do
        subject.pointer.to_a.should == [:a, 'b']
      end
    end
    
    describe "#inc" do
      it "returns an integer" do
        subject.pos = 1
        subject.inc.should be_kind_of Integer
      end
    
      it "increments pointer position" do
        expect {
          subject.inc
        }.to change {subject.pos}.by(1)
      end
      
      it "doesn't increment pointer when at end of tokens" do
        subject.pos = 4
        expect {
          subject.inc
        }.to change {subject.pos}.by(0)
      end
    end
    
    describe "#dec" do
      it "returns an integer" do
        subject.pos = 3
        subject.dec.should be_kind_of Integer
      end
    
      it "decrements pointer position" do
        subject.pos = 4
        expect {
          subject.dec
        }.to change {subject.pos}.by(-1)
      end

      it "doesn't decrement pointer when at start of tokens" do
        subject.pos = 0
        expect {
          subject.dec
        }.to change {subject.pos}.by(0)
      end
    end
    
    describe "#pointing_at?" do
      it "returns true if type matches token type" do
        subject.pointing_at?(:a).should be_true
      end
      
      it "returns false if type doesn't match token type" do
        subject.pointing_at?(:z).should be_false
      end
    end
    
    describe "#pointing_at" do
      it "returns type of current token" do
        subject.pointing_at.should == :a
      end
    end
    
    describe "#peek" do
      it "returns +len+ tokens from current token" do
        subject.peek(2).to_a.should == [[:a, 'b'], [:c, 'd']]
      end
      
      it "returns all tokens if length given is too big" do
        subject.peek(5).should == subject
      end
    end
    
    describe "#scan" do
      it "returns current token" do
        subject.scan.to_a.should == [:a, 'b']
      end
      
      it "increments the pointer" do
        expect {
          subject.scan
        }.to change {subject.pos}.by(1)
      end
      
      context "when given type" do
        it "returns current token if types match" do
          subject.scan(:a).to_a.should == [:a, 'b']
        end
        
        it "raises error if types doesn't match" do
          lambda {
            subject.scan(:z)
          }.should raise_error(Ast::Tokens::Error)
        end
      end
    end
    
    describe "#check" do
      it "returns current token" do
        subject.check.to_a.should == [:a, 'b']
      end
      
      it "doesn't increment pointer" do
        expect {
          subject.check
        }.to change {subject.pos}.by(0)
      end
      
      context "when given type" do
        it "returns current token if types match" do
          subject.check(:a).to_a.should == [:a, 'b']
        end
        
        it "raises error if types doesn't match" do
          lambda {
            subject.check(:z)
          }.should raise_error(Ast::Tokens::Error)
        end
      end
    end
    
    describe "#skip" do
      it "increments pointer" do
        expect {
          subject.skip
        }.to change {subject.pos}.by(1)
      end
      
      context "when given type" do
        it "increments pointer if type matches current token" do
          expect {
            subject.skip(:a)
          }.to change {subject.pos}.by(1)
        end

        it "raises error if types don't match" do
          lambda {
            subject.skip(:z)
          }.should raise_error(Ast::Tokens::Error)
        end
      end
    end
    
    describe "#eot?" do
      it "returns false if not at end of tokens" do
        subject.pos = 1
        subject.eot?.should be_false
      end
      
      it "returns true if at end of tokens" do
        subject.pos = 4
        subject.eot?.should be_true
      end
    end
    
    describe "#scan_until" do
      specify { subject.scan_until(:d).should be_kind_of Ast::Tokens }
      
      it "contains last matched item" do
        subject.scan_until(:c).last.type.should == :c
      end
      
      it "return rest of tokens if no match found" do
        subject.scan_until(:z).should == subject
      end
      
      it "increments pointer" do
        expect {
          subject.scan_until(:c)
        }.to change {subject.pos}.by(2)
      end
    end
    
    describe "#check_until" do
      specify{ subject.check_until(:d).should be_kind_of Ast::Tokens }
      
      it "contains last matched item" do
        subject.check_until(:c).last.type.should == :c
      end
      
      it "returns rest of tokens if no match found" do
        subject.check_until(:z).should == subject
      end
      
      it "doesn't change pointer" do
        expect {
          subject.check_until(:c)
        }.to change {subject.pos}.by(0)
      end
    end
    
    describe "#skip_until" do
      specify { subject.skip_until(:d).should be_kind_of Integer }
      
      it "counts last matched item" do
        subject.skip_until(:c).should == 2
      end
      
      it "counts to end of tokens if no match found" do
        subject.skip_until(:z).should == subject.length
      end
      
      it "increments pointer" do
        expect {
          subject.skip_until(:c)
        }.to change {subject.pos}.by(2)
      end
    end
    
    describe "#rest" do
      it "returns all tokens after and including current token" do
        subject.pos = 3
        subject.rest.to_a.should == [[:g, 'h'], [:i, 'j']]
      end
    end
    
    describe "#clear" do
      it "sets pointer to end of tokens" do
        subject.clear
        subject.pos.should == 4
      end
    end
    
    describe "#unscan" do
      it "sets pointer to last position" do
        subject.scan
        subject.unscan
        subject.pos.should == 0
      end
      
      it "sets previous position to nil" do
        subject.scan
        subject.unscan
        subject.prev_pos.should be_nil
      end
    end
  
  end
  
  context "when enumerating" do
  
    subject {
      Ast::Tokens.new([[:a, 'b'], [:a, 'b'], [:a, 'b']])
    }
  
    describe "#each" do
      it "passes type and value to block" do
        subject.each do |t, v|
          t.should == :a
          v.should == 'b'
        end
      end
    end
    
    describe "#each_type" do
      it "passes type to block" do
        subject.each_type do |t|
          t.should == :a
        end
      end    
      
      it "doesn't pass value to block" do
        subject.each_type do |t, v|
          v.should_not == 'b'
        end
      end
    end
    
    describe "#each_value" do
      it "passes value to block" do
        subject.each_value do |v|
          v.should == 'b'
        end
      end
      
      it "doesn't pass type to block" do
        subject.each_value do |v, t|
          t.should_not == :a
        end
      end
    end
    
    describe "#each_token" do
      it "passes tokens to block" do
        subject.each_token do |t|
          t.should be_kind_of Ast::Token
        end
      end
    end
  
  end

end