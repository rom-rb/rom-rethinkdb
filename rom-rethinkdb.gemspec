# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rom/rethinkdb/version'

Gem::Specification.new do |spec|
  spec.name          = 'rom-rethinkdb'
  spec.version       = ROM::RethinkDB::VERSION
  spec.authors       = ['Krzysztof Wawer']
  spec.email         = ['krzysztof.wawer@gmail.com']
  spec.summary       = 'RethinkDB support for ROM'
  spec.description   = spec.summary
  spec.homepage      = 'http://rom-rb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'rethinkdb'
  spec.add_runtime_dependency 'rom', '~> 4.0'
  spec.add_runtime_dependency 'connection_pool', '>= 0.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
end
