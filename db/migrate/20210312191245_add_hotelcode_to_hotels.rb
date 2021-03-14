class AddHotelcodeToHotels < ActiveRecord::Migration[5.2]
  def change
    add_column :hotels, :hotel_reservation_code, :integer
    add_reference :hotels, :reservation_manager, foreign_key: true 

  end
end
