class AddPricePerToArticles < ActiveRecord::Migration[7.0]
  def change
    add_column :articles, :price_per, :float, default: 0.0
    add_column :articles, :unit_symbol, :string
  end
end
