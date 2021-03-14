class AddReferencesToRoomCategories < ActiveRecord::Migration[5.2]
  def change
    add_reference :room_categories, :hotel, foreign_key: true 
  end
end
