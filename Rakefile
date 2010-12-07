require 'rake'
require 'rspec/core/rake_task'

require File.expand_path('../lib/ast_ast/version', __FILE__)

desc "Run rspec"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

task :publish => ['release:pre', 'release:build', 'release:push']


# Tag stuff is partially from `gem this`, I would use it but don't
# think it fits what I need. Nor would I write my own, there
# are way too many different tools for this sort of thing.
namespace :release do

  desc 'Last minute checks before pushing'
  task :pre => [:spec] do
    require 'highline/import'
    ok = ask "OK to publish (y/n): "
    if ok.strip != "y"
      exit 0
    end
    
    tag = ask "Create tag for ast_ast v#{Ast::VERSION} (y/n): "
    if tag.strip == "y"
      Rake::Task['release:tag'].invoke
    end
  end
  
  desc 'Tag vX.X.X'
  task :tag do
    if `git diff --cached`.empty?
      if `git tag`.split("\n").include?("v#{Ast::VERSION}")
        raise "Version #{Ast::VERSION} has already been tagged"
      end
      system "git tag v#{Ast::VERSION}"
      system 'git push origin --tags'
      system 'git push origin master'
    else
      raise "Unstaged changes still waiting to be commited"
    end
  end
  
  desc 'Build gemspec'
  task :build do
    system "gem build ast_ast.gemspec"
    system "mkdir -p pkg"
    system "mv ast_ast-#{Ast::VERSION}.gem pkg/ast_ast-#{Ast::VERSION}.gem"
  end
  
  desc 'Push to RubyGems'
  task :push do
    system "gem push pkg/ast_ast-#{Ast::VERSION}.gem"
  end
end
