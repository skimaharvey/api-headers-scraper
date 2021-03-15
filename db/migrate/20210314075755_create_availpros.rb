class CreateAvailpros < ActiveRecord::Migration[5.2]
  def change
    create_table :availpros do |t|

      t.timestamps
    end
  end
end
