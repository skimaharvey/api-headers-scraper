class AddOtapriceToPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :ota_price, :integer
  end
end
