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

  spec.files         = %x(git ls-files -z).split("\x0").reject do |f|
    f.match(%r{^test/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib ext)
  spec.extensions = 'ext/vying/c/parts/board/extconf.rb'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
end
