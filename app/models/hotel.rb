class Hotel < ApplicationRecord
    has_many :room_categories, dependent:  :destroy
    has_many :scraping_errors, dependent:  :destroy
    has_many :scraping_sessions, dependent:  :destroy
    has_many :prices, dependent:  :destroy
    belongs_to :user, optional: true
    has_many :hotel_competitors, dependent:  :destroy
    has_one :hotel_owner, dependent:  :destroy
end
