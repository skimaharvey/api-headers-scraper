class AddReferencesToOtacoefficients < ActiveRecord::Migration[5.2]
  def change
    add_reference :ota_coefficients, :hotel, foreign_key: true 
  end
end
