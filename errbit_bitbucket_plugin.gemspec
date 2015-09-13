# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'errbit_bitbucket_plugin/version'

Gem::Specification.new do |spec|
  spec.name          = 'errbit_bitbucket_plugin'
  spec.version       = ErrbitBitbucketPlugin::VERSION
  spec.authors       = ['Matthew McFarling']
  spec.email         = ['matt@codemancode.com']
  spec.summary       = %q{BitBucket integration for Errbit.}
  spec.description   = %q{BitBucket integration for Errbit.}
  spec.homepage      = 'https://github.com/codemancode/errbit_bitbucket_plugin'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'errbit_plugin'
  spec.add_dependency 'bitbucket_rest_api', '0.1.7'
  spec.add_dependency 'faraday', '~> 0.9.1'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
