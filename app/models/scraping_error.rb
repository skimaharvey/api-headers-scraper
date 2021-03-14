class ScrapingError < ApplicationRecord
    belongs_to :hotel 
    belongs_to :date_of_price
end
