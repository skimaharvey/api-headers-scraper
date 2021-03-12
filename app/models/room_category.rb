class RoomCategory < ApplicationRecord
    has_many :prices, dependent: :destroy
    belongs_to :hotel
end
