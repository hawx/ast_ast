require 'rubygems'
require 'test/unit'
require 'shoulda'

require File.join(File.dirname(__FILE__), '..', 'lib', 'ast_ast')

class Test::Unit::TestCase

  def assert_token(item)
    assert Ast::Token.valid?(item)
  end

end
