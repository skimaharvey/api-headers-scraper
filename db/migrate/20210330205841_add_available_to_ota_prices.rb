class AddAvailableToOtaPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :ota_prices, :available, :boolean
  end
end
