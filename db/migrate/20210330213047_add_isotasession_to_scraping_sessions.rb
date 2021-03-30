class AddIsotasessionToScrapingSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :scraping_sessions, :is_ota_type, :boolean
  end
end
