class NewPrice < ApplicationRecord
  belongs_to :room_category
  belongs_to :date_of_price
  belongs_to :hotel
end
