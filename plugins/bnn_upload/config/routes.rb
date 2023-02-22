Rails.application.routes.draw do
  scope '/:foodcoop' do
    get '/order/:id/send_result_to_supplier_modal', controller: 'orders', action: :send_result_to_supplier_modal, as: :order_send_result_to_supplier_modal
    post '/order/:id/send_result_to_supplier', controller: 'orders', action: :send_result_to_supplier, as: :send_result_to_supplier
  end
end
