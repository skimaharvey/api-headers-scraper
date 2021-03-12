class Hotel < ApplicationRecord
    has_many :room_categories, dependent:  :destroy
    has_many :scraping_errors, dependent:  :destroy
    has_many :scraping_sessions, dependent:  :destroy
    has_many :prices, dependent:  :destroy
end
