require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/clean'
require 'fileutils'
include FileUtils

###
### cleanup tasks
###

CLEAN.include( 'ext/**/*.o', 'ext/**/*.so', 'ext/**/*.class', 'ext/**/*.jar' )
CLOBBER.include( 'pkg', 'doc/api', 'doc/coverage', 'lib/vying/version.rb' )

###
### test tasks
###

Rake::TestTask.new do |t|
  t.libs << "test" << "ext"
  t.ruby_opts << "-r rubygems"
  t.test_files = FileList['test/**/*_test.rb']
end

task :"test_sans_ext" => [:clobber, :test, :compile]

Rake::TestTask.new do |t|
  t.name = "test_core"
  t.libs << "test" << "ext"
  t.ruby_opts << "-r rubygems"
  t.test_files = FileList.new( 'test/**/*_test.rb' ) do |list|
    list.exclude( 'test/vying/rules/**/*' )
  end
end

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
### task to compile the C extension
###

desc "compile the C extension part of the vying library"
task :compile do 
  sh %{cd ext/vying/c/parts/board && ruby ./extconf.rb && make}
end

###
### task to compile the Java extension
###

desc "compile the Java extension part of the vying library"
task :compile_java do
  cp = ENV['JRUBY_HOME'] && FileList["#{ENV['JRUBY_HOME']}/lib/*.jar"]
  cp = cp.join( File::PATH_SEPARATOR )

  dir = "ext/vying/java/parts/board"

  sh %{cd #{dir} && javac -cp #{cp} *.java}
  sh %{cd #{dir} && jar cf vying_board_ext.jar *.class}
  sh %{mv #{dir}/vying_board_ext.jar ext/}
end

###
### the default task
###

task :default => [:clean, :compile, :test]

###
###  RubyGems related tasks follow:
###

# Try to load the version number -- it's okay if it's not available

begin
  require 'lib/vying/version.rb'
rescue Exception
  module Vying; end
end

desc "Appends the value in VERSION to lib/vying/version.rb"
task :version do
  v = ENV['VERSION']
  raise "provide a VERSION via the environment variable" unless v
  sh %{echo 'module Vying; VERSION = "#{v}"; end' >> lib/vying/version.rb}
end

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  nil
end

if defined?( Gem ) && Vying.const_defined?( 'VERSION' )
  task :gem => [:clean, :compile, :test]

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
    s.version = Vying::VERSION
    s.summary = 'Vying Game Library'
    s.description = 'Vying is a game library.'
    s.homepage = 'http://vying.org/dev/public'
    s.rubyforge_project = 'silence stupid WARNINGS'
    s.has_rdoc = true
    s.files = PKG_FILES.to_a
    s.extensions = "ext/vying/c/parts/board/extconf.rb"
    s.executables = ['vying']
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
    s.version = Vying::VERSION
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
  Rcov::RcovTask.new do |t|
    t.libs << "test" << "ext"
    t.test_files = FileList['test/**/*_test.rb']
    t.output_dir = "doc/coverage"
  end
end

