Mailer.class_eval do
  require 'foodsoft_bnn_upload/order_bnn'
  def add_order_result_attachments(order, options = {})
    # attachments['order.pdf'] = ::OrderFax.new(order, options).to_pdf if options[:file_formats][:pdf].present?
    # attachments['order.csv'] = ::OrderCsv.new(order, options).to_csv if options[:file_formats][:csv].present?
    attachments['order.bnn'] = FoodsoftBnnUpload::OrderBnn.new(order, options).to_csv if options[:file_formats][:bnn].present?
  end
end
