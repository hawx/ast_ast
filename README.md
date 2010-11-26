# AstAst


                          sSSSSs
                    saaAAA     Tttttts
                   sa   tT  t  TT    tt
            saaaaaaA  t tT  t  TT     Ts
           sa  tt  T    tT  t  TT     Ts   
     - -  AaaaaaaAaaaaAAt     TsssssTs
             tT      t tSTSsssSTt tt
                     t tt       t tt
                    st tt      st tt  
                   S t tt     S t tt  
                    st tt      st tt  
                     t tt       t tt
                     t tts      t tts
                     S tS s     S tS ss
                    tsssstss   tsssstSSS
  


## How To 
### String -> Ast::Tokens

So you have a string, eg:

    an example String, lorem!

And you want to turn it into a set of tokens, for some reason, but can't be bothered messing around with `strscan` so instead use `Ast::Tokeniser`

    string = "an example String, lorem!"
    
    class StringTokens < Ast::Tokeniser
    
      # A rule uses a regular expression to match against the string given
      # if it matches a token is created with the name given, eg. +:article+
      rule :article, /an|a|the/
      rule :word,    /[a-z]+/
      rule :punct,   /,|\.|!/
      
      # A rule can be passed a block that then modifies the match and returns
      # something new in it's place, here we are removing the capital.
      rule :pronoun, /[A-Z][a-z]+/ do |i|
        i.downcase
      end
    end
    
    StringTokens.tokenise(string)
    #=> #< [0] <:article, "an">, <:word, "example">, <:pronoun, "string">, <:punct, ",">, <:word, "lorem">, <:punct, "!"> >
    

### Ast::Tokens -> Ast::Tree

Later.

## Goals/Ideas

Now that it is possible to take a string and turn it into a set of tokens, I want to be able to take the tokens and turn them into a tree structure. This should be easy to write using a similar DSL to Tokeniser. See below for an idea on how this might be done, though of course when I start writing it, it will change _a lot_.
 
### Ast::Ast

Imagine we have a string:

    string = <<EOS
    def method
      print 'hi'
    end
    EOS

Which becomes these tokens:

    tokens #=> [:defn], [:id, 'method'], [:id, 'print'], [:string, 'Hi'], [:end]

We're looking for a tree like this:
  
    tree #=> [:defn, 'method', [
      [:id, 'print', [
        [:string, 'Hi']
      ]]
    ]]

Then the class could look something like (something being the keyword):

    class MyAst < Ast::Ast
    
      # create a defn token
      token :defn do
        [
          # start with :defn
          :defn,
          
          # get the name of method by reading next :id
          read_next(:id), # if not :id throw error
          
          # read rest of block, until the matching :end
          [read_until(:end)]
        ]
      end
      
      # allows you to use the name given in place of a list of token names
      group :literal, [:string, :integer, :float]
      # really just creates an array which responds to name given
      group :defined, [:print, :puts, :putc, :gets, :getc]
      
      token :id do |t, v|
        case v
        when 'method'
          v
        when :defined
          [:call, v, [read_next(:literal)]]
        else
          [t, v]
        end
      end
      
      token(:string) {|i| i } # not really necessary
    end

## Copyright

Copyright (c) 2010 Joshua Hawxwell. See LICENSE for details.
