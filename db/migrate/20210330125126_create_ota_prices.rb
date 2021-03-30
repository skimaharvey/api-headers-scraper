class CreateOtaPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :ota_prices do |t|
      t.integer :price
      t.string :provider
      t.timestamps
    end
  end
end
