class CreateNewReservations < ActiveRecord::Migration[5.2]
  def change
    create_table :new_reservations do |t|
      t.references :room_category, foreign_key: true
      t.references :date_of_price, foreign_key: true
      t.integer :price
      t.integer :n_units
      t.references :hotel, foreign_key: true

      t.timestamps
    end
  end
end
