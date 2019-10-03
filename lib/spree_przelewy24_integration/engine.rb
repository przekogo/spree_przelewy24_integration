module SpreePrzelewy24Integration
  class Engine < Rails::Engine
    require 'spree_core'
    isolate_namespace Spree
    engine_name 'spree_przelewy24_integration'

    config.autoload_paths += %W(#{config.root}/lib)
    
    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc

    initializer "spree.gateway.payment_methods",
      after: "spree.register.payment_methods" do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::Przelewy24
    end
  end
end