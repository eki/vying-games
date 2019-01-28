# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.libs << 'ext'
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = false
end

RuboCop::RakeTask.new

task default: :test

namespace :ci do
  desc 'Run continuous integration checks'
  task check: %w(test rubocop)
end

CLEAN.include('ext/**/*.o', 'ext/**/*.so', 'ext/**/*.bundle')
CLOBBER.include('pkg', 'coverage/', 'test/coverage/')

task "test_sans_ext": [:clobber, :test, :compile]

desc 'compile the C extension part of the vying library'
task :compile do
  ruby = $PROGRAM_NAME =~ /rake(.+)/ ? "ruby#{Regexp.last_match(1)}" : 'ruby'
  sh "cd ext/vying/c/parts/board && #{ruby} ./extconf.rb && make"
end
