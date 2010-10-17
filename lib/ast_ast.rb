$: << File.join(File.dirname(__FILE__), '..')
__DIR__ = File.dirname(__FILE__)

require 'strscan'

require File.join(__DIR__, 'ast_ast/ast')
require File.join(__DIR__, 'ast_ast/tree')
require File.join(__DIR__, 'ast_ast/tokeniser')
require File.join(__DIR__, 'ast_ast/token')