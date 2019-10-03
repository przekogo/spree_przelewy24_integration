
FactoryBot.define do
  # Define your Spree extensions Factories within this file to enable applications, and other extensions to use and override them.
  #
  # Example adding this to your spec_helper will load these Factories for use:
  # require 'spree_payu_integration/factories'

  factory :przelewy24_payment_method, class: Spree::PaymentMethod::Przelewy24 do
    name { 'Przelewy24' }
    preferences { { test_crc_key: 'super_secret_key', p24_id_sprzedawcy: '213123' } }
  end
end