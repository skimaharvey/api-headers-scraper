class AddUrlToSynxisHelpers < ActiveRecord::Migration[5.2]
  def change
    add_column :synxis_helpers, :url, :string
  end
end
