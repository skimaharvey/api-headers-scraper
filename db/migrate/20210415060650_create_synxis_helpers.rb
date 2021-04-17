class CreateSynxisHelpers < ActiveRecord::Migration[5.2]
  def change
    create_table :synxis_helpers do |t|
      t.references :hotel, foreign_key: true
      t.integer :chain_ref
      t.integer :hotel_ref

      t.timestamps
    end
  end
end
