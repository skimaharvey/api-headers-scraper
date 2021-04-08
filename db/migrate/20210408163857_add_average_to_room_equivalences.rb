class AddAverageToRoomEquivalences < ActiveRecord::Migration[5.2]
  def change
    add_column :room_equivalences, :average_price, :float
    add_column :room_equivalences, :median_price, :float
  end
end
