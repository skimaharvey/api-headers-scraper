class AddReferencesToOtaPrices < ActiveRecord::Migration[5.2]
  def change
    add_reference :ota_prices, :hotel, foreign_key: true
    add_reference :ota_prices, :date_of_price, foreign_key: true
  end
end
