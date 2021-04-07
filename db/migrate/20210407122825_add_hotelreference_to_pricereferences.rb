class AddHotelreferenceToPricereferences < ActiveRecord::Migration[5.2]
  def change
    add_reference :price_equivalences, :hotel, foreign_key: true
  end
end
