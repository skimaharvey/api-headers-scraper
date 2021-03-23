class AddCapacityToHotels < ActiveRecord::Migration[5.2]
  def change
    add_column :hotels, :capacity, :integer
  end
end
