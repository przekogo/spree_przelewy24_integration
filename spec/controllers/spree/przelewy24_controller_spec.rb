require 'spec_helper'

RSpec.describe Spree::Przelewy24Controller, type: :controller do
  let(:user) { stub_model(Spree::LegacyUser) }
  let(:order) { OrderWalkthrough.up_to(:payment) }
  
  before do
    order.number = 'R225803212'
    order.token = 'VtBI0GqFyIPntMORUKxTwA1571850323146'
    user.email = 'mr@test.gg'
  end
  
  let(:payment_method) { FactoryBot.create :przelewy24_payment_method }
  let(:confirm_transaction_params) do
    {
      payment_method_id: payment_method.id,
      order_id: order.id,
      p24_session_id: 'R225803212',
      p24_amount: order.total,
      p24_order_id: '300207705',
      p24_pos_id: '213123',
      p24_merchant_id: '213123',
      p24_method: '25',
      p24_statement: 'p24-B20-A77-A05',
      p24_currency: 'PLN',
      p24_sign: '82374f7dfbaf84f305f9685c51535cc6'
    }
  end
  let(:response_body) { 'error=0' }
  let(:request_body) {
    {
      p24_amount: '2999',
      p24_crc: '52e3f4497fe4eb770e726cf40c1a887f',
      p24_merchant_id: '213123',
      p24_order_id: '300207705',
      p24_pos_id: '213123',
      p24_session_id: order.number
    }
  }
  let(:request_headers) {
    {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type'=>'application/x-www-form-urlencoded',
      'Host'=>'secure.przelewy24.pl',
      'User-Agent'=>'Ruby'
    }
  }
  let!(:verify_transaction) do
    stub_request(:post, "https://secure.przelewy24.pl/trnVerify").
      with(
        body: request_body,
        headers: request_headers
      ).
      to_return(status: 200, body: response_body, headers: {})
  end


  describe "POST /przelewy24/confirm_transaction" do

    subject { post :confirm_transaction, params: confirm_transaction_params }

    context 'when verified succesfully' do
      it 'registeres a payment' do
        expect(order.payments.count).to eq(0)
        expect { subject }.not_to raise_error
        expect(order.payments.count).to eq(1)
        expect(order.payments.first.amount).to eq(0.29e0)
      end
    end

    context 'verification fails' do
      let(:response_body) { 'error=1&errorMessage=omg it failed' }
      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with("CRITICAL Payment verification FAILED. Error code: 1. Error message: omg it failed")
        subject
      end

      it 'does not register any payment' do
        expect { subject }.not_to raise_error
        expect(order.payments.count).to eq(0)
      end
    end

    context 'connection to Przelewy24 fails' do
      let!(:verify_transaction) do
        stub_request(:post, "https://secure.przelewy24.pl/trnVerify").
          with(
            body: request_body,
            headers: request_headers
          ).
          to_raise(Timeout::Error.new)
      end
      it 'logs the error' do
        expect(Rails.logger).to receive(:error).with("CRITICAL Payment verification FAILED. Connection to Przelewy24 timed out")
        subject
      end

      it 'does not register any payment' do
        expect { subject }.not_to raise_error
        expect(order.payments.count).to eq(0)
      end
    end

  end
end