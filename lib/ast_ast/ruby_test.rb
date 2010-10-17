
require File.dirname(__FILE__) + "/../ast_ast"

<<EOS # sample code
class Simple
  def add(n1, n2)
    return n1 + n2
  end
end
EOS

<<EOS # the tokens
[:class], [:id, 'Simple'],
  [:def], [:id, 'add'], [:oparen], [:id, 'n1'], [:id, 'n2'], [:cparen],
    [:return], [:id, 'n1'], [:id, :+], [:id, 'n2'],
  [:end],
[:end]
EOS

<<EOS # above as AST
[:class,
 :Simple,
 [:const, :Object],
 [:defn,
  :add,
  [:scope,
   [:block,
    [:args, :n1, :n2],
    [:return, [:call, [:lvar, :n1],
               :+, [:array, [:lvar, :n2]]]]]]]]
EOS

class RubyAst < Ast::Ast

  # :class ... :end
  block :class => :end do |r|
    id = nil
    if r.check && r.check.type == :id
      id = r.scan
    end
    
    a = [:class]
    a << id.value if id
    a << [:const, :Object]
    a << r.rest
    a
  end
  
  block :defn => :end do |r|
    r
  end
=begin
  # :defn ... :end
  token :not do
    [:defn, 
     scan(:id).value,
     [:scope, 
      [:block,
       (check.type != :oparen ? p('hi') : nil),
       [:args], 
       scan_until(:end)
      ]
     ]
    ]
  end
=end
end

code = Ast::Tokens.new([
[:class], [:id, 'Simple'],
  [:defn], [:id, 'add'], [:oparen], [:id, 'n1'], [:id, 'n2'], [:cparen],
    [:return], [:id, 'n1'], [:id, :+], [:id, 'n2'],
  [:end],
[:end]
])
p RubyAst.astify(code)