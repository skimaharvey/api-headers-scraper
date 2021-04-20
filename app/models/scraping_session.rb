class ScrapingSession < ApplicationRecord
    belongs_to :hotel
    has_many :prices, dependent: :destroy
    has_many :room_reservations, dependent: :destroy
end
