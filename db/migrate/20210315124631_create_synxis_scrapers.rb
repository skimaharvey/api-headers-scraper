class CreateSynxisScrapers < ActiveRecord::Migration[5.2]
  def change
    create_table :synxis_scrapers do |t|

      t.timestamps
    end
  end
end
