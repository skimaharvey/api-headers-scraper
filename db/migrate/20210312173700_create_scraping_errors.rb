class CreateScrapingErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :scraping_errors do |t|
      t.datetime :date

      t.timestamps
    end
  end
end
