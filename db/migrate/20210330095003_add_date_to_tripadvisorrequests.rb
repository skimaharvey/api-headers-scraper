class AddDateToTripadvisorrequests < ActiveRecord::Migration[5.2]
  def change
    add_column :tripadvisor_requests, :date, :string
  end
end
