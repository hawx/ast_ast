# AstAst


                    sSSSSs
              saaAAA     Tttttts
             sa   tT  t  TT    tt
      saaaaaaA  t tT  t  TT     Ts
     sa  tt  T    tT  t  TT     Ts   
     AaaaaaaAaaaaAAt     TsssssTs
       tT      t tSTSsssSTt tt
               t tt       t tt
              st tt      st tt  
             S t tt     S t tt  
              st tt      st tt  
               t tt       t tt
               t tts      t tts
               S tS s     S tS ss
              tsssstss   tsssstSSS




__VERY IMPORTANT:__ it is probably a very bad idea to use this in something that relies on it. It will change without warning!

## Goals/Ideas

Crazy simple string -> token converting, using regular expression rules and optional blocks. Some of the finer points of this still need working out, mainly should you be able to affect the name of the token within the block.

    class MyTokeniser < Ast::Tokeniser
      rule :long, /--[a-zA-Z0-9]+/
      rule :short, /-[a-zA-Z0-9]+/
      rule :word, /[a-zA-Z0-9]+/
    end
    input = "--along -sh aword"
    MyTokeniser.tokenise(input)
    #=> #<Ast::Tokens [[:long, "--along"], [:short, "-sh"], [:word, "aword"]]>
    
    # Use blocks to change results, passes matches
    class MyTokeniser < Ast::Tokeniser
      rule :long, /--([a-zA-Z0-9]+)/ {|i| i[1]}
      rule :short, /-([a-zA-Z0-9]+)/ {|i| i[1].split} # creates an array so splits into multiple tokens
      rule :word, /[a-zA-Z0-9]+/
    end
    input = "--along -sh aword"
    MyTokeniser.tokenise(input)
    #=> #<Ast::Tokens [[:long, "along"], [:short, "s"], [:short, "h"], [:word, "aword"]]>

 
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
      [:call, 'print', [
        [:string, 'Hi']
      ]]
    ]]

Then the class could look something like (something being the keyword):

    class MyAst < Ast::Ast
    
      # create a defn token
      token :defn do
        # return isn't really necessary
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
