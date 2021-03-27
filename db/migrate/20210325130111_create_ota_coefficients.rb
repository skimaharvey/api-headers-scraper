class CreateOtaCoefficients < ActiveRecord::Migration[5.2]
  def change
    create_table :ota_coefficients do |t|
      t.boolean :is_coefficient
      t.float :coefficient_value

      t.timestamps
    end
  end
end
