class AddReferencesToScrapingerrors < ActiveRecord::Migration[5.2]
  def change
    add_reference :scraping_errors, :hotel, foreign_key: true 
  end
end
