
require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.libs << 'ext'
  t.test_files = FileList['test/**/*_test.rb']
end

RuboCop::RakeTask.new

task default: :test

namespace :ci do
  desc 'Run continuous integration checks'
  task check: %w(test rubocop)
end

CLEAN.include( 'ext/**/*.o', 'ext/**/*.so', 'ext/**/*.class', 'ext/**/*.jar',
  'ext/**/*.bundle' )
CLOBBER.include( 'pkg', 'doc/api', 'doc/coverage' )

task :"test_sans_ext" => [:clobber, :test, :compile]

desc "compile the C extension part of the vying library"
task :compile do 
  ruby = ($0 =~ /rake(.+)/) ? "ruby#{$1}" : "ruby"
  sh %{cd ext/vying/c/parts/board && #{ruby} ./extconf.rb && make}
end
