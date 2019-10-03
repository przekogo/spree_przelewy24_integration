module Spree
  class PaymentMethod::Przelewy24 < PaymentMethod

    preference :p24_id_sprzedawcy, :string
    preference :production_crc_key, :string
    preference :test_crc_key, :string
    preference :p24_language, :string, :default => "pl"
    preference :test_mode, :boolean, :default => false

    def payment_profiles_supported?
      false
    end

    def p24_amount(amount)
      (amount*100.00).to_i.to_s #total amount * 100
    end

    def register_url
      przelewy24_url + '/trnRegister'
    end

    def direct_url
      przelewy24_url + '/trnDirect'
    end

    def payment_url
      przelewy24_url + '/trnRequest'
    end

    def verify_url
      przelewy24_url + '/trnVerify'
    end

    def crc_key
      preferred_test_mode ? preferred_test_crc_key : preferred_production_crc_key
    end

    private

    def przelewy24_url
      if preferred_test_mode
        'https://sandbox.przelewy24.pl'
      else
        'https://secure.przelewy24.pl'
      end
    end

  end
end