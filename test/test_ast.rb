require File.join(File.dirname(__FILE__) ,'helper')

class TestAst < Test::Unit::TestCase
  context "When trying examples" do
    should "run readme example" do
      tokens = [[:def], [:id, "my_method"], [:oparen], [:id, "arg"], [:cparen],
                [:return], [:id, "arg"], [:id, :+], [:int, 3],
                [:end]]
      
      class SentenceTree < Ast::Ast
        block :def => :end do |b|
          tree = Ast::Tree.new
          b.each do |t|
            case t
            when Ast::Token
              tree << t
            when Ast::Tree
              tree << t
            end
          end
          tree
        end
        
        block :oparen => :cparen
        group :var, [:int, :id]
        
        token :id do |t|
          case t.value
          when Symbol
            tree = Ast::Tree.new
            tree << Ast::Token.new(:call, t.value)
            tree << scan(:var)
          else
            t
          end
        end
        
      end
      
      tokens = Ast::Tokens.new(tokens)
      p SentenceTree.astify(tokens)
      
    end
  end
end