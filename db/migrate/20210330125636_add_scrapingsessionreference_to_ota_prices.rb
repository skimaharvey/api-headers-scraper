class AddScrapingsessionreferenceToOtaPrices < ActiveRecord::Migration[5.2]
  def change
    add_reference :ota_prices, :scraping_session, foreign_key: true
    add_column :scraping_errors, :available, :boolean
  end
end
