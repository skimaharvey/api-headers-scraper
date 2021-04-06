class ChangeDateofpriceDateToDate < ActiveRecord::Migration[5.2]
  def up
    change_column :date_of_prices, :date, :date
  end
  
  def down
    change_column :date_of_prices, :date, :datetime
  end
end
