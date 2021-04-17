class AddRoomscategoriesfieldsToRoomCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :room_categories, :size, :integer
    add_column :room_categories, :max_capacity, :integer
  end
end
