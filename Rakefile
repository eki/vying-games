require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/clean'
require 'fileutils'
include FileUtils

# Try to load the version number -- it's okay if it's not available

begin
  require 'lib/version.rb'
rescue Exception
  nil
end

###
### cleanup tasks
###

CLEAN.include( 'ext/**/*.o', 'ext/**/*.so', 'lib/version.rb' )
CLOBBER.include( 'pkg', 'doc/api', 'doc/coverage' )

###
### test task
###

Rake::TestTask.new do |t|
  t.libs << "test" << "ext"
  t.test_files = FileList['test/**/*_test.rb']
end

task :"test_sans_ext" => [:clobber, :test, :compile]

###
### rdoc task
###

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_dir = "doc/api"
  rd.rdoc_files.include( "README", "LICENSE", "COPYING", 
                         "doc/*.txt", "lib/**/*.rb", 
                         "ext/**/*.h", "ext/**/*.c" )
end

###
### task to compile the extension
###

desc "compile the C extension part of the vying library"
task :compile do 
  sh %{cd ext/vying/parts/board && ruby ./extconf.rb && make}
end

###
### the default task
###

task :default => [:clean, :compile, :test]

###
###  RubyGems related tasks follow:
###

desc "Appends the tagged version to lib/vying.rb"
task :version do
  v = ENV['VERSION']
  raise 'provide a VERSION via the environment variable" unless v
  sh %{echo 'module Vying; VERSION = "#{v}"; end' >> lib/version.rb}
end

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end

if defined?( Gem ) && Vying::VERSION
  task :gem => [:clean, :compile, :test, :version]

  PKG_FILES = FileList[
    'lib/**/*',
    'bin/vying',
    'test/**/*',
    'ext/**/*',
    'doc/**/*',
    'Rakefile',
    'README',
    'LICENSE',
    'COPYING']

  spec = Gem::Specification.new do |s|
    s.name = 'vying'
    s.version = Vying.version
    s.summary = 'Vying Game Library'
    s.description = 'Vying is a game library.'
    s.homepage = 'http://vying.org/dev/public'
    s.rubyforge_project = 'silence stupid WARNINGS'
    s.has_rdoc = true
    s.files = PKG_FILES.to_a
    s.extensions = "ext/vying/board/extconf.rb"
    s.executables = ['vying']
    s.add_dependency "random", ">= 0.2.1"
    s.require_paths << "ext"
    s.author = 'Eric K Idema'
    s.email = 'eki@vying.org'
  end

  package_task = Rake::GemPackageTask.new( spec ) do |pkg|
    pkg.need_tar_gz = true
    pkg.need_zip = true
  end

  PKG_FILES_NO_EXT = FileList[
    'lib/**/*',
    'bin/vying',
    'test/**/*',
    'doc/**/*',
    'Rakefile',
    'README',
    'LICENSE',
    'COPYING']

  spec_pure = Gem::Specification.new do |s|
    s.name = 'vying-pure'
    s.version = Vying.version
    s.summary = 'Vying Game Library (Pure Ruby)'
    s.description = 'Vying is a game library.'
    s.homepage = 'http://vying.org/dev/public'
    s.rubyforge_project = 'silence stupid WARNINGS'
    s.has_rdoc = true
    s.files = PKG_FILES_NO_EXT.to_a
    s.executables = ['vying']
    s.author = 'Eric K Idema'
    s.email = 'eki@vying.org'
  end

  package_task = Rake::GemPackageTask.new( spec_pure ) do |pkg|
    pkg.need_tar_gz = true
    pkg.need_zip = true
  end
end

###
### Rcov related tasks follow
###

begin
  require 'rcov/rcovtask'
rescue Exception
  nil
end

if defined?( Rcov )
  task :rcov => [:compile]

  Rcov::RcovTask.new do |t|
    t.libs << "test" << "ext"
    t.test_files = FileList['test/**/*_test.rb']
    t.output_dir = "doc/coverage"
  end
end

