class MigrateMessageBodyToActionText < ActiveRecord::Migration[7.0]
  include ActionView::Helpers::TextHelper
  def change
    rename_column :messages, :body, :body_old
    Message.all.each do |message|
      message.update_attribute(:body, simple_format(message.body_old))
    end
    remove_column :messages, :body_old
  end
end
