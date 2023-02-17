class Mailer
  # attaches files to mail sent to supplier
  def add_order_result_attachments(order, options = {})
    attachments['order.pdf'] = OrderFax.new(order, options).to_pdf if options[:file_formats][:pdf].present?
    attachments['order.csv'] = OrderCsv.new(order, options).to_csv if options[:file_formats][:csv].present?
    attachments['order.bnn'] = OrderBnn.new(order, options).to_bnn if options[:file_formats][:bnn].present?
  end
end
