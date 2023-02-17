Rails.application.routes.draw do
  scope '/:foodcoop' do
    get '/order/send_result_to_supplier_modal' => 'orders#send_result_to_supplier_modal'
  end
end
