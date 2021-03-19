class RenameReferencesToHotelowners < ActiveRecord::Migration[5.2]
  def change
    rename_column :hotel_owners, :user_id_id, :user_id
    rename_column :hotel_owners, :hotel_id_id, :hotel_id
    rename_column :hotel_competitors, :user_id_id, :user_id
    rename_column :hotel_competitors, :hotel_id_id, :hotel_id
  end
end
