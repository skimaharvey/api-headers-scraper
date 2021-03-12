class AddScrapingsessionreferenceToScrapingErrors < ActiveRecord::Migration[5.2]
  def change
    add_reference :scraping_errors, :scraping_session, foreign_key: true 
  end
end
