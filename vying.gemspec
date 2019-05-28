# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vying/version'

Gem::Specification.new do |spec|
  spec.name          = 'vying'
  spec.version       = Vying::VERSION
  spec.authors       = ['Eric K Idema']
  spec.email         = ['eki@vying.org']

  spec.summary       = 'Vying Game Library'
  spec.description   = 'Vying is a game library.'
  spec.homepage      = 'https://github.com/eki/vying'

  spec.files         = Dir['lib/**/*', 'bin/*', 'ext/**/*.{rb,c,h}',
                         'ext/**/Makefile', 'README', 'LICENSE']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib ext)
  spec.extensions    = 'ext/vying/c/parts/board/extconf.rb'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'oj'
end
