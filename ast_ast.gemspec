# -*- encoding: utf-8 -*-
require File.expand_path("lib/ast_ast/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "ast_ast"
  s.version     = Ast::VERSION
  s.author      = "Joshua Hawxwell"
  s.email       = "m@hawx.me"
  s.homepage    = "http://github.com/hawx/ast_ast"
  s.has_rdoc    = false
  s.summary     = "String -> Tokens (-> Tree)"
  s.description = <<EOD
Easily convert strings into tokens.
In the future you will be able to convert these into a tree as well, but this is far from finished.
EOD

  s.add_development_dependency "rspec", ">= 2.1"
  
  s.files        = Dir['Rakefile', 'LICENSE', 'README.md', '{bin,lib,spec}/**/*'] & `git ls-files -z`.split("\0")
  s.test_files   = Dir['test/**/*']
  s.require_path = 'lib'
end
