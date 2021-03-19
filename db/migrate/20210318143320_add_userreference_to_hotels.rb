class AddUserreferenceToHotels < ActiveRecord::Migration[5.2]
  def change
    add_reference :hotels, :user, foreign_key: true
  end
end
