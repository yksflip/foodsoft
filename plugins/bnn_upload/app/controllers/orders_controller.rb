class OrdersController < ApplicationController
  # Send a order to the supplier.
  def send_result_to_supplier
    order = Order.find(params[:id])
    options = { file_formats: params[:file_formats] }
    order.send_to_supplier!(@current_user, options)
    redirect_to order, notice: I18n.t('orders.send_to_supplier.notice')
  rescue => error
    redirect_to order, alert: I18n.t('errors.general_msg', :msg => error.message)
  end
  def send_result_to_supplier_modal
    @order = Order.find(params[:id])
  end
end
