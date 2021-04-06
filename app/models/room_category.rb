class RoomCategory < ApplicationRecord
    has_many :prices, dependent: :destroy
    belongs_to :hotel
    has_one :room_equivalence, dependent: :destroy
    has_one :price_equivalence, through: :room_equivalence
end
