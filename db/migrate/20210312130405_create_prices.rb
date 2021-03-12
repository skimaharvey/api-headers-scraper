class CreatePrices < ActiveRecord::Migration[5.2]
  def change
    create_table :prices do |t|
      t.integer :price
      t.boolean :available
      t.integer :n_of_units_available

      t.timestamps
    end
  end
end
