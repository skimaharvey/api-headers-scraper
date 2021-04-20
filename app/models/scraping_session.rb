class ScrapingSession < ApplicationRecord
    belongs_to :hotel
    has_many :prices, dependent: :destroy
    has_many :new_reservations, dependent: :destroy
end
