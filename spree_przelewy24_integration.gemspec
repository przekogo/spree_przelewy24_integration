$:.push File.expand_path("lib", __dir__)

require "spree_przelewy24_integration/version"

Gem::Specification.new do |spec|
  spec.name          = "spree_przelewy24_integration"
  spec.version       = SpreePrzelewy24Integration::VERSION
  spec.authors       = "przekogo"
  spec.email         = "przekogo@gmail.com"

  spec.summary       = "Spree integration with Przelewy24"
  spec.description   = "Spree integration with Przelewy24"
  spec.homepage      = "https://github.com/przekogo/spree_przelewy24_integration"
  spec.license       = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency 'spree', '~> 3.7'
  spec.add_dependency 'spree_auth_devise', '~> 3.5'
  spec.add_dependency 'spree_gateway', '~> 3.4'
  spec.add_dependency 'devise', '>4.7'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency 'rspec-activemodel-mocks'
  spec.add_development_dependency 'factory_bot_rails'
  spec.add_development_dependency 'ffaker'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency "sqlite3"
end
