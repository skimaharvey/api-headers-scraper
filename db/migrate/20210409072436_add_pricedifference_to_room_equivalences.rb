class AddPricedifferenceToRoomEquivalences < ActiveRecord::Migration[5.2]
  def change
    add_column :room_equivalences, :price_difference, :integer
  end
end
