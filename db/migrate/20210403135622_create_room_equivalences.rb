class CreateRoomEquivalences < ActiveRecord::Migration[5.2]
  def change
    create_table :room_equivalences do |t|
      t.boolean :is_percentage
      t.boolean :is_addition

      t.timestamps
    end
  end
end
