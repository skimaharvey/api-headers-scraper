class OtaScrapersController < ApplicationController
    def launch_scraper_all_hotels
        all_competitors_ids = HotelCompetitor.where(user_id: params["user_id"]).map{|hotel|
            hotel.id
        }
        hotel_user_id = HotelOwner.find_by(user_id: params["user_id"]).id 
        all_competitors_ids.push(hotel_user_id)
        
        all_competitors_ids.each{|hotel_id|
            OtaScraperJob.perform_later(hotel_id)
        }
        render json: {"message": "Fetching all ota's prices"}
    end

    def scraper_specific_hotel
        OtaScraperJob.perform_later(params["hotel_id"])
        render json: {"message": "Fetching ota's prices"}
    end
end
