class CreateRoomCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :room_categories do |t|
      t.string :name
      t.integer :room_code
      t.integer :number_of_units

      t.timestamps
    end
  end
end
