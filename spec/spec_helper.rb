# Run Coverage report
require 'simplecov'
SimpleCov.start do
  add_filter 'spec/dummy'
  add_filter 'spec'
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
  add_group 'Libraries', 'lib'
end

# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec/rails'
require 'database_cleaner'
require 'ffaker'
require 'factory_bot'
require 'webmock/rspec'
require 'rspec/active_model/mocks'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

# Requires factories defined in spree_core
require 'spree/testing_support/factories'
require 'spree/testing_support/order_walkthrough'
require 'spree/testing_support/controller_requests'
require 'spree/testing_support/preferences'
require 'spree/testing_support/authorization_helpers'
require 'spree/testing_support/url_helpers'

require 'spree_przelewy24_integration/factories'

RSpec.configure do |config|
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, type: :controller

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Ensure Suite is set to use transactions for speed.
  config.before :suite do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  # Before each spec check if it is a Javascript test and switch between using database transactions or not where necessary.
  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  # After each spec clean the database.
  config.after :each do
    DatabaseCleaner.clean
  end

end

config = YAML::load(IO.read(File.dirname(__FILE__) + "/dummy/config/database.yml"))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/dummy/log/debug.log")
ActiveRecord::Base.establish_connection(config["test"])
load(File.dirname(__FILE__) + "/dummy/db/schema.rb")