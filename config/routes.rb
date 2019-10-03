Spree::Core::Engine.routes.draw do
  # Add your extension routes here
  post '/przelewy24/confirm_transaction/:payment_method_id/:order_id/', to: 'przelewy24#confirm_transaction', as: :przelewy24_confirm_transaction
end