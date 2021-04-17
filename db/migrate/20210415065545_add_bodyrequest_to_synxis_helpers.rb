class AddBodyrequestToSynxisHelpers < ActiveRecord::Migration[5.2]
  def change
    add_column :synxis_helpers, :body_request, :text
  end
end
