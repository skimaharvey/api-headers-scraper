class AddDateofpricereferenceToScrapingErrors < ActiveRecord::Migration[5.2]
  def change
    add_reference :scraping_errors, :date_of_price, foreign_key: true 
  end
end
