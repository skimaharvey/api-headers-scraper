class CreateNewPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :new_prices do |t|
      t.references :room_category, foreign_key: true
      t.references :date_of_price, foreign_key: true
      t.integer :old_price
      t.integer :new_price
      t.integer :n_units
      t.references :hotel, foreign_key: true

      t.timestamps
    end
  end
end
