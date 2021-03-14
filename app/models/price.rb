class Price < ApplicationRecord
    belongs_to :hotel
    belongs_to :date_of_price
    belongs_to :room_category
    belongs_to :scraping_session
end
