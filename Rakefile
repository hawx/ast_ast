require 'rake'
require 'grancher/task'

require File.expand_path('../lib/ast_ast/version', __FILE__)

Grancher::Task.new do |g|
  g.branch    = 'gh-pages'
  g.push_to   = 'origin'
  g.directory = 'doc'
end

namespace :release do
  task :tag do
    system("git tag v#{Ast::VERSION}")
    system('git push origin --tags')
  end
end
