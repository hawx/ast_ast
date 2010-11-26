$: << File.join(File.dirname(__FILE__), '..')

require 'duvet'
Duvet.start :filter => 'ast_ast/lib'

require 'lib/ast_ast'
require 'rspec'

RSpec.configure do |config|
  config.color_enabled = true
end