class AddPriceequivalencereferenceToRoomEquivalence < ActiveRecord::Migration[5.2]
  def change
    add_reference :room_equivalences, :price_equivalence, foreign_key: true
  end
end
