class AddReferencesToHotelowners < ActiveRecord::Migration[5.2]
  def change
    add_reference :hotel_competitors, :user, foreign_key: true 
    add_reference :hotel_competitors, :hotel, foreign_key: true 
    add_reference :hotel_owners, :user, foreign_key: true 
    add_reference :hotel_owners, :hotel, foreign_key: true 
  end
end
