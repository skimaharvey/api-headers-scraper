class CreateHotelOwners < ActiveRecord::Migration[5.2]
  def change
    create_table :hotel_owners do |t|
      t.timestamps
    end
  end
end
