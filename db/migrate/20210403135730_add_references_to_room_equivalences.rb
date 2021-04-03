class AddReferencesToRoomEquivalences < ActiveRecord::Migration[5.2]
  def change
    add_reference :room_equivalences, :hotel, foreign_key: true
    add_reference :room_equivalences, :room_category, foreign_key: true
  end
end
