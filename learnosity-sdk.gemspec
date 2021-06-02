# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'learnosity/sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'learnosity-sdk'
  spec.version       = Learnosity::Sdk::VERSION
  spec.authors       = [ 'Olivier Mehani', 'learnosity' ]
  spec.email         = [ 'olivier.mehani@learnosity.com', 'licenses@learnosity.com' ]

  spec.summary       = 'SDK to interact with Learnosity APIs'
  spec.homepage      = 'https://github.com/Learnosity/learnosity-sdk-ruby/'

  spec.license	     = 'Apache-2.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sys-uname', '>= 1.0'

  spec.add_development_dependency 'bundler', '~> 2.2.10'
  spec.add_development_dependency 'rake', '~> 12.3.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
end

# vim: sw=2
