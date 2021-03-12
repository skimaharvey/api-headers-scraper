class ScrapingSession < ApplicationRecord
    belongs_to :hotel
    has_many :prices, dependent: :destroy
end
