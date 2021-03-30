class AddReferenceToTripadvisorrequests < ActiveRecord::Migration[5.2]
  def change
    add_reference :tripadvisor_requests, :hotel, foreign_key: true 
  end
end
