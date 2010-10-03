
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
    [:class,
     scan(:id).value,
     [:const, :Object],
     r
    ]
  end
  
  # :defn ... :end
  token :defn do
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
end

code = Ast::Tokens.new([
[:class], [:id, 'Simple'],
  [:defn], [:id, 'add'], [:oparen], [:id, 'n1'], [:id, 'n2'], [:cparen],
    [:return], [:id, 'n1'], [:id, :+], [:id, 'n2'],
  [:end],
[:end]
])
p RubyAst.astify(code)