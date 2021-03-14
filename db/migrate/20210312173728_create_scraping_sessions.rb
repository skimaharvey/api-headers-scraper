class CreateScrapingSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :scraping_sessions do |t|
      t.datetime :date

      t.timestamps
    end
  end
end
