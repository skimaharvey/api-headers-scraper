class AddResponseToScrapingErrors < ActiveRecord::Migration[5.2]
  def change
    add_column :scraping_errors, :response, :text
  end
end
