class AddReservationurlToHotels < ActiveRecord::Migration[5.2]
  def change
    add_column :hotels, :reservation_url, :string
  end
end
