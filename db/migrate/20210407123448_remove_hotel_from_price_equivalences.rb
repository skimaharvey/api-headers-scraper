class RemoveHotelFromPriceEquivalences < ActiveRecord::Migration[5.2]
  def change
    remove_reference :price_equivalences, :hotel, foreign_key: true
    add_reference :price_equivalences, :user, foreign_key: true
  end
end
