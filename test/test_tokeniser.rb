require 'helper'

class TestTokeniser < Test::Unit::TestCase
  context "When trying examples" do
    should "run first" do
      class Klass < Ast::Tokeniser
        rule(:word, /[a-z]+/) {|i| i.reverse}
      end
      result = [[:word, "sdrawkcab"], [:word, "forwards"]]
      assert_equal result, Klass.tokenise("backwards sdrawrof")
    end
  end
end
