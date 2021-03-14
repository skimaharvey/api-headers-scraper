class AddReferencesToScrapingSessions < ActiveRecord::Migration[5.2]
  def change
    add_reference :scraping_sessions, :hotel, foreign_key: true 
  end
end
