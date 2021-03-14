class AddReferencesToPrices < ActiveRecord::Migration[5.2]
  def change
    add_reference :prices, :hotel, foreign_key: true 
    add_reference :prices, :date_of_price, foreign_key: true 
    add_reference :prices, :room_category, foreign_key: true 
    add_reference :prices, :scraping_session, foreign_key: true 
  end
end
