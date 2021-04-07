class ReplaceHotelreferenceByUserReferenceToRoomEquivalence < ActiveRecord::Migration[5.2]
  def change
    remove_reference :room_equivalences, :hotel, foreign_key: true
    add_reference :room_equivalences, :user, foreign_key: true
  end
end
