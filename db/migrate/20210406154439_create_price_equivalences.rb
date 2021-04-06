class CreatePriceEquivalences < ActiveRecord::Migration[5.2]
  def change
    create_table :price_equivalences do |t|
      t.integer :price_category

      t.timestamps
    end
  end
end
