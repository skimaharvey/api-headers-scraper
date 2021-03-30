class CreateTripadvisorRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :tripadvisor_requests do |t|
      t.text :request_body
      t.string :proxy
      t.string :hotel_name

      t.timestamps
    end
  end
end
