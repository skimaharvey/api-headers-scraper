class RenameAvailproToAvailproScraper < ActiveRecord::Migration[5.2]
  def change
    rename_table :availpros, :scraper_availpros
  end
end
