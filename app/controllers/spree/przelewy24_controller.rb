module Spree
  class Przelewy24Controller < Spree::BaseController
    protect_from_forgery with: :reset_session 

    def confirm_transaction
      begin
        logger.info "Incoming payment verification from Przelewy24 with params: #{params}"
        order = Order.find(params[:order_id])
        payment_method = PaymentMethod.find(params[:payment_method_id])
        verification_response = verify_transaction(payment_method, order, params)
        if verification_response['error'] == '0'
          finalize_payment_for(order, payment_method, params[:p24_amount])
          order.update_totals
          order.finalize!
          logger.info "Order finalized. Order id:#{order.id}"
        else
          logger.error "CRITICAL Payment verification FAILED. Error code: #{verification_response['error']}. Error message: #{verification_response['errorMessage']}" # This case would indicate configuration problem or an attack(!) possibly preventing all payments from registering and thus causing major pain in the ass.
        end
      rescue Timeout::Error # would be awesome to create a job here to try again later
        logger.error "CRITICAL Payment verification FAILED. Connection to Przelewy24 timed out"
      end
    end

    private

    def verify_transaction(payment_method, order, params)
      request_params = {
        p24_merchant_id: params[:p24_merchant_id],
        p24_pos_id: params[:p24_pos_id],
        p24_session_id: params[:p24_session_id],
        p24_amount: (order.total*100).to_i,
        p24_order_id: params[:p24_order_id],
        p24_crc: Digest::MD5.hexdigest("#{params[:p24_session_id]}|#{params[:p24_order_id]}|#{(order.total*100).to_i}|#{order.currency}|#{payment_method.crc_key}")
      }
      uri = URI(payment_method.verify_url)
      Net::HTTP.post_form(uri, request_params).body.split('&').map{|r| r.split('=')}.to_h # handle http-like response attributes
    end

    def finalize_payment_for(order, payment_method, amount)
      payment = order.payments.create!(amount: amount.to_i/100.0, source: payment_method, payment_method_id: payment_method.id)
      payment.started_processing
      payment.complete
    end
  end
end