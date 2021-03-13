class CreateReservitScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :reservit_scrapers do |t|

      t.timestamps
    end
  end
end
