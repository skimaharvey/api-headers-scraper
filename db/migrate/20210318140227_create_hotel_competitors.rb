class CreateHotelCompetitors < ActiveRecord::Migration[5.2]
  def change
    create_table :hotel_competitors do |t|
      t.timestamps
    end
  end
end
