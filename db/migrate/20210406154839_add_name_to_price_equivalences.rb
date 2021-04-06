class AddNameToPriceEquivalences < ActiveRecord::Migration[5.2]
  def change
    add_column :price_equivalences, :name, :string
  end
end
