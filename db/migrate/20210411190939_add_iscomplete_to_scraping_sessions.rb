class AddIscompleteToScrapingSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :scraping_sessions, :is_complete, :boolean
  end
end
