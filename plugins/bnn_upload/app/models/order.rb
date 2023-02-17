class Order
  def send_to_supplier!(user, options = {})
    Mailer.deliver_now_with_default_locale do
      Mailer.order_result_supplier(user, self, options)
    end
    update!(last_sent_mail: Time.now)
  end
end
