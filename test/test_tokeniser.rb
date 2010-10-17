require File.join(File.dirname(__FILE__) ,'helper')

class TestTokeniser < Test::Unit::TestCase
  context "When trying examples" do
    should "run first" do
      class Word < Ast::Tokeniser
        rule(:word, /[a-z]+/) {|i| i.reverse}
      end
      result = [[:word, "sdrawkcab"], [:word, "forwards"]]
      assert_equal result, Word.tokenise("backwards sdrawrof")
    end
    
    should "run readme example" do
      class SentenceTokens < Ast::Tokeniser
        rule :pronoun, /(I|you|he|she|it)/
        rule :verb,    /(have|had|will have|play|played|will play)/ # etc
        rule :article, /(a|an|the)/
        rule :class,   /(Object|Class|String|Array)/ # etc
        rule :punct,   /[.,!]/ # etc
      end
      result = [[:pronoun, "I"], [:verb, "have"], [:article, "a"], [:class, "String"], [:punct, "!"]]
      assert_equal result, SentenceTokens.tokenise("I have a String!")
    end
  end
  

  context "A Sinple tokeniser" do
    
    setup do
      @rules = class Klass < Ast::Tokeniser
        rule :word, /[a-z]+/
        rule :caps, /[A-Z][a-z]+/
        rule(:number, /[0-9]+/) {|i| i.to_i}
      end
    end
    
    should "create rules" do
      assert_equal 3, @rules.size
    end
    

    context "A rule" do
      setup do
        @rule = @rules[0]
      end
      
      should "have a name" do
        assert_equal :word, @rule.name
      end
      
      should "have a regular expression" do
        assert_equal /[a-z]+/, @rule.regex 
      end
      
      should "have a block" do
        assert @rule.block
      end
    end

    should "create tokens" do
      input = "John has 10 houses in Berlin."
      result = [[:caps, "John"], [:word, "has"], [:number, 10], [:word, "houses"], [:word, "in"], [:caps, "Berlin"]]
      assert_equal result, Klass.tokenise(input)
    end
    
  end
  
end
