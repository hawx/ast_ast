require 'spec_helper'

describe Ast::Tokeniser::Rule do
  subject { Ast::Tokeniser::Rule.new(:test, /test/) }
  
  describe "#name" do
    specify { subject.name.should be_kind_of Symbol }
  end
  
  describe "#regex" do
    specify { subject.regex.should be_kind_of Regexp }
  end
  
  describe "#block" do
    specify { subject.block.should be_kind_of Proc }
    context "when no block is given" do
      it "use default proc which returns argument" do
        subject.block.call(1).should == 1
      end
    end
  end
  
  describe "#run" do
    
    context "when returning a string" do
      subject { Ast::Tokeniser::Rule.new(:rword, /[a-z]+/) {|i| i.reverse } }
    
      it "runs the block" do
        subject.run("hello").should == "olleh"
      end
    end
    
    context "when returning an array" do
      subject { Ast::Tokeniser::Rule.new(:letter, /[a-z]+/) {|i| i.split('') } }
    
      it "runs the block" do
        subject.run("hello").should == %w(h e l l o)
      end
    end
  end
end

describe Ast::Tokeniser do

  describe ".rule" do
    
    class Klass1 < Ast::Tokeniser
      rule :over, /b/
    end
     
    it "adds a new rule to list" do
      Klass1.rule(:test, /c/)
      Klass1.rules.map {|i| i.name}.should include :test
    end
    
    it "overwrites existing rules with same name" do
      Klass1.rule(:over, /a/)
      Klass1.rules.find_all {|i| i.name == :over}.size.should == 1
    end
  end
  
  describe ".tokenise" do
  
    class Klass2 < Ast::Tokeniser
      rule :long, /--([a-zA-Z0-9]+)/ do |i| 
        i[1]
      end
      
      rule :short, /-([a-zA-Z0-9]+)/ do |i| 
        i[1].split('')
      end
      
      rule :word, /[a-zA-Z0-9]+/
    end
    
    specify { Klass2.tokenise("").should be_kind_of Ast::Tokens }
    
    it "retuns the correct tokens" do
      r = Klass2.tokenise("--along -sh aword")
      r.to_a.should == [[:long, "along"], [:short, "s"], [:short, "h"], [:word, "aword"]]
    end
    
    it "runs example in Readme" do
      string = "an example String, lorem!"
      
      class StringTokens < Ast::Tokeniser
        rule :article, /an|a|the/
        rule :word,    /[a-z]+/
        rule :punct,   /,|\.|!/

        rule :pronoun, /[A-Z][a-z]+/ do |i|
          i.downcase
        end
      end
      
      r = [[:article, "an"], [:word, "example"], [:pronoun, "string"], [:punct, ","], [:word, "lorem"], [:punct, "!"]]
      StringTokens.tokenise(string).to_a.should == r
    end
  end

end