class AddReferencesToNewReservations < ActiveRecord::Migration[5.2]
  def change
    add_reference :new_reservations, :scraping_session, foreign_key: true
    add_column :new_reservations, :scraping_comparaison_id, :integer
  end
end
