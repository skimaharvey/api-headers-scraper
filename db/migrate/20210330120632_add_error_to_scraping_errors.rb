class AddErrorToScrapingErrors < ActiveRecord::Migration[5.2]
  def change
    add_column :scraping_errors, :error, :text
    add_column :scraping_errors, :price_type_ota, :boolean
    add_column :scraping_errors, :price_type_hotel, :boolean
  end
end
