class RoomCategory < ApplicationRecord
    has_many :prices, dependent: :destroy
    belongs_to :hotel
    has_many :room_equivalences, dependent: :destroy
end
