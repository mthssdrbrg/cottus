# encoding: utf-8

$: << File.expand_path('../lib', __FILE__)

require 'cottus/version'

Gem::Specification.new do |s|
  s.name        = 'cottus'
  s.version     = Cottus::VERSION
  s.authors     = ['Mathias Söderberg']
  s.email       = ['mths@sdrbrg.se']
  s.homepage    = 'https://github.com/mthssdrbrg/cottus'
  s.summary     = %q{Multi limp HTTP client}
  s.description = %q{HTTP client for making requests against a set of hosts}
  s.license     = 'Apache License 2.0'

  s.files         = Dir['lib/**/*.rb', 'README.md']
  s.test_files    = Dir['spec/**/*.rb']
  s.require_paths = %w(lib)

  s.add_runtime_dependency 'httparty'

  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
end
