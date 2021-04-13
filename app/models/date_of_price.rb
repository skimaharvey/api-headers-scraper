class DateOfPrice < ApplicationRecord
    has_many :prices, dependent:  :destroy
    has_many :scraping_errors, dependent:  :destroy
    has_many :ota_prices, dependent: :destroy
    
    def self.for_the_next_90_days
        todays_date = Date.today
        200.times { 
            unless DateOfPrice.where(date: todays_date.to_s).present?
                DateOfPrice.create(date: todays_date)
            end
            todays_date = todays_date.next_day(1)
        }
    end
end
