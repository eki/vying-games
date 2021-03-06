# frozen_string_literal: true

require_relative 'lib/vying/games/version'

Gem::Specification.new do |spec|
  spec.name          = 'vying-games'
  spec.version       = Vying::Games::VERSION
  spec.authors       = ['Eric K Idema']
  spec.email         = ['eki@vying.org']

  spec.summary       = 'Vying Game Library'
  spec.description   = 'Vying is a game library.'
  spec.homepage      = 'https://github.com/eki/vying-games'

  spec.files         = Dir['lib/**/*', 'bin/*', 'ext/**/*.{rb,c,h}',
    'ext/**/Makefile', 'README', 'LICENSE']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib ext)
  spec.extensions    = 'ext/vying/games/c/parts/board/extconf.rb'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'

  spec.add_dependency 'oj'
end
