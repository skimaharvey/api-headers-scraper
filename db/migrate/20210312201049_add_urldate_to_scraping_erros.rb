class AddUrldateToScrapingErros < ActiveRecord::Migration[5.2]
  def change
    add_column :scraping_errors, :url_date, :string
  end
end
