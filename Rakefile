require 'rake'

require File.expand_path('../lib/ast_ast/version', __FILE__)

namespace :release do
  task :tag do
    system("git tag v#{Ast::VERSION}")
    system('git push origin --tags')
  end
end
