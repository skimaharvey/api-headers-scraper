class CreateProxies < ActiveRecord::Migration[5.2]
  def change
    create_table :proxies do |t|
      t.string :proxy_body
      t.integer :port
      t.string :username
      t.string :password

      t.timestamps
    end
  end
end
