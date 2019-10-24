module Spree
  module CheckoutControllerDecorator
    def self.prepended(base)
      base.before_action :pay_with_przelewy24, only: :update
    end
    
    private

    def pay_with_przelewy24
      begin
        return unless params[:state] == 'payment'
        return if params[:order].blank? || params[:order][:payments_attributes].blank?

        pm_id = params[:order][:payments_attributes].first[:payment_method_id]
        payment_method = Spree::PaymentMethod.find(pm_id)

        if payment_method && payment_method.kind_of?(Spree::PaymentMethod::Przelewy24)
          p24_params = prepare_register_transaction_przelewy24_params(payment_method)
          register_transaction_response = register_transaction_przelewy24(payment_method, p24_params)
          @order.save
          logger.info("Przelewy24 transaction registration params: #{p24_params}")
          if register_transaction_response['error']=='0'
            logger.info("Token recived: #{register_transaction_response['token']}. Redirecting user to Przelewy24 for payment")
            redirect_to "#{payment_method.payment_url}/#{register_transaction_response['token']}"
          else
            logger.error "Registering transaction with Przelewy24 FAILED. Error code: #{register_transaction_response['error']}. Error message: #{register_transaction_response['errorMessage']}"
            @order.destroy
            redirect_to root_path, alert: I18n.t("spree.register_transaction_error")
          end
        end
        
        rescue Timeout::Error
          logger.error "Registering transaction with Przelewy24 FAILED. Connection timed out"
          @order.destroy
          redirect_to root_path, alert: I18n.t("spree.przelewy24_timeout")
      end
    end

    def prepare_register_transaction_przelewy24_params(payment_method)
      p24_params = {
        p24_merchant_id: payment_method.preferences[:p24_id_sprzedawcy],
        p24_pos_id: payment_method.preferences[:p24_id_sprzedawcy],
        p24_session_id: @order.number,
        p24_amount: (@order.total*100).to_i, # conversion to przelewy24 required integer format 
        p24_currency: @order.currency,
        p24_description: "Zamowienie nr #{@order.number}",
        p24_email: @order.email,
        p24_country: 'PL',
        p24_url_return: order_url(@order, {checkout_complete: true, order_token: @order.token}), notice: I18n.t("spree.order_completed"),
        p24_url_status: przelewy24_confirm_transaction_url(payment_method.id, @order.id),
        p24_api_version: '3.2'
      }
      p24_params.merge!(p24_sign: Digest::MD5.hexdigest("#{p24_params[:p24_session_id]}|#{payment_method.preferences[:p24_id_sprzedawcy]}|#{p24_params[:p24_amount]}|#{p24_params[:p24_currency]}|#{payment_method.crc_key}"))
    end

    def register_transaction_przelewy24(payment_method, p24_params)
      uri = URI(payment_method.register_url)
      Net::HTTP.post_form(uri, p24_params).body.split('&',2).map{|r| r.split('=')}.to_h # handle http-like response attributes
    end

  end
end

::Spree::CheckoutController.prepend ::Spree::CheckoutControllerDecorator