# encoding: utf-8

Gem::Specification.new do |spec|
  spec.name    = 'busy_bunny'
  spec.version = '0.0.1'

  spec.author      = 'codequest'
  spec.email       = 'marcinw@codequest.com'
  spec.description = 'AMQP helpers'
  spec.summary     = 'Useful abstractions over base AMQP protocol handlers'
  spec.homepage    = 'https://github.com/codequest-eu/busy-bunny'
  spec.license     = 'MIT'

  spec.files      = `git ls-files`.split($RS)
  spec.test_files = spec.files.grep(/^spec/)

  spec.add_development_dependency 'bundler', '>= 1.6.9'
  spec.add_development_dependency 'rake', '~> 10.3'
end
