require 'spec_helper'

RSpec.describe Spree::CheckoutController, type: :controller do
  let(:user) { stub_model(Spree::LegacyUser) }
  let(:order) { OrderWalkthrough.up_to(:payment) }

  before do
    user.email = 'mr@test.gg'
    order.number = 'R225803212'
    order.token = 'VtBI0GqFyIPntMORUKxTwA1571850323146'
    allow(controller).to receive(:try_spree_current_user).and_return(user)
    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(controller).to receive(:current_order).and_return(order)
  end

  describe 'PATCH /checkout/update/payment' do
    context 'when payment_method is Przelewy24' do
      let(:payment_method) { FactoryBot.create :przelewy24_payment_method }
      let(:payment_params) do
        {
          state: 'payment',
          order: { payments_attributes: [{ payment_method_id: payment_method.id }] }
        }
      end
      let(:response_body) { 'error=0&token=p24supertoken' }
      let(:request_body) {
        {
          notice: 'translation missing: en.spree.order_completed',
          p24_amount: '2999',
          p24_api_version: '3.2',
          p24_country: 'PL',
          p24_currency: 'USD',
          p24_description: 'Zamowienie nr R225803212',
          p24_email: 'mr@test.gg',
          p24_merchant_id: '213123',
          p24_pos_id: '213123',
          p24_session_id: 'R225803212',
          p24_sign: '8cfa3e9fd9cc82b24f5eb7f4540dc20f',
          p24_url_return: 'http://test.host/orders/R225803212?checkout_complete=true&order_token=VtBI0GqFyIPntMORUKxTwA1571850323146',
          p24_url_status: 'http://test.host/przelewy24/confirm_transaction/2/1'
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
      let!(:register_transaction_przelewy24) do
        stub_request(:post, 'https://secure.przelewy24.pl/trnRegister').
          with(
            body: request_body,
            headers: request_headers
          ).
          to_return(status: 200, body: response_body, headers: {})
      end

      subject { post :update, params: payment_params }

      context 'when przelewy24 returns no error' do
        it 'registers transaction in przelewy24 and redirects to external payment page' do
          expect { subject }.not_to raise_error
          expect(register_transaction_przelewy24).to have_been_requested
          expect(subject).to redirect_to('https://secure.przelewy24.pl/trnRequest/p24supertoken')
        end
      end

      context 'when przelewy24 returns an error' do
        let(:response_body) { 'error=1&errorMessage=p24_merchantId:Incorrect merchant_id&p24_posId:Incorrect pos_id&p24_email:Empty p24_email&p24_urlReturn:Empty p24_urlReturn&p24_urlCancel:Empty p24_urlCancel&p24_amount:Incorrect value' }
        it 'redirects to homepage with error message' do
          expect { subject }.not_to raise_error
          expect(register_transaction_przelewy24).to have_been_requested
          expect(subject).to redirect_to(root_path)
          expect(flash[:alert]).to eq('An error occured while processing your order. Please try again.')
        end
      end

      context 'when przelewy24 does not respond' do
        let!(:register_transaction_przelewy24) do
        stub_request(:post, 'https://secure.przelewy24.pl/trnRegister').
          with(
            body: request_body,
            headers: request_headers
          ).
          to_raise(Timeout::Error.new)
        end

        it 'redirects to homepage with error message' do
          expect { subject }.not_to raise_error
          expect(register_transaction_przelewy24).to have_been_requested
          expect(subject).to redirect_to(root_path)
          expect(flash[:alert]).to eq('Connection to Przelewy24 failed. Please try again later.')
        end

      end

    end
  end
end