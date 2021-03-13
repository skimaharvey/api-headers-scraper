class AddTypenametoRoomCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :room_categories, :room_type_name, :string
  end
end
