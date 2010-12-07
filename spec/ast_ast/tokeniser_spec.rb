require 'spec_helper'

describe Ast::Tokeniser::Rule do
  subject { Ast::Tokeniser::Rule.new(:test, /test/) }
  
  describe "#name" do
    specify { subject.name.should be_kind_of Symbol }
  end
  
  describe "#regex" do
    specify { subject.regex.should be_kind_of Regexp }
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
    
    class KlassRule < Ast::Tokeniser
      rule :over, /b/
    end
     
    it "adds a new rule to list" do
      KlassRule.rule(:test, /c/)
      KlassRule.rules.map {|i| i.name}.should include :test
    end
    
    it "overwrites existing rules with same name" do
      KlassRule.rule(:over, /a/)
      KlassRule.rules.find_all {|i| i.name == :over}.size.should == 1
    end
  end
  
  describe ".token" do
    
    class KlassToken < Ast::Tokeniser
      token /[a-z]+/ do |i|
        if i.include? "a"
          Ast::Token.new(:a_tok, i)
        else
          Ast::Token.new(:not_a, i)
        end
      end
    end
    
    it "adds a new rule to list" do
      KlassToken.rules.map {|i| i.regex}.should include /[a-z]+/
    end
    
  end
  
  describe ".missing" do
  
    class KlassMissing < Ast::Tokeniser
      missing do |i|
        Ast::Token.new(i, i)
      end
    end
    
    it "creates a proc" do
      KlassMissing.missing.should be_kind_of Proc
    end
    
    it "invokes the proc when a match is not found" do
      KlassMissing.tokenise("abc").to_a.should == [["a", "a"], ["b", "b"], ["c", "c"]]
    end
  
  end
  
  describe ".tokenise" do
  
    class KlassTokenise < Ast::Tokeniser
      
      commands = %w(git commit status)
    
      rule :long, /--([a-zA-Z0-9]+)/ do |i| 
        i[1]
      end
      
      rule :short, /-([a-zA-Z0-9]+)/ do |i| 
        i[1].split('')
      end
      
      token /[a-zA-Z0-9]+/ do |i|
        if commands.include?(i)
          Ast::Token.new(:command, i)
        else
          Ast::Token.new(:word, i)
        end
      end
      
    end
    
    specify { KlassTokenise.tokenise("").should be_kind_of Ast::Tokens }
    
    it "retuns the correct tokens" do
      r = KlassTokenise.tokenise("git --along -sh aword")
      r.to_a.should == [[:command, "git"], [:long, "along"], [:short, "s"], [:short, "h"], [:word, "aword"]]
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