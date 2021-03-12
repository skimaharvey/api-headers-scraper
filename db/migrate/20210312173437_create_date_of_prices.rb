class CreateDateOfPrices < ActiveRecord::Migration[5.2]
  def change
    create_table :date_of_prices do |t|
      t.datetime :date

      t.timestamps
    end
  end
end
