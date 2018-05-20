
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'freshdesk_api_v2/version'

Gem::Specification.new do |spec|
  spec.name          = 'freshdesk_api_v2'
  spec.version       = FreshdeskApiV2::VERSION
  spec.authors       = ['Matt Payne']
  spec.email         = ['paynmatt@gmail.com']

  spec.summary       = 'Initial Gem wrapping the Freshdesk V2 API'
  spec.description   = 'This Gem wraps the Freshdesk V2 API'
  spec.homepage      = 'https://github.com/thinkific/freshdesk_api_v2'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'excon', '~> 0.62.0'
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'nitlink', '~> 1.1'
  spec.add_dependency 'addressable', '~> 2.5', '>= 2.5.2'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'byebug', '~> 9.0.6'
  spec.add_development_dependency 'rubocop', '~> 0.52.1'
end
