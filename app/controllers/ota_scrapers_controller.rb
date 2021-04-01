class OtaScrapersController < ApplicationController
    def launch_scraper_all_hotels
        all_competitors_ids = HotelCompetitor.where(user_id: params["user_id"]).map{|hotel|
            hotel.id
        }
        hotel_user_id = HotelOwner.find_by(user_id: params["user_id"]).id 
        all_competitors_ids.push(hotel_user_id)
        
        all_competitors_ids.each{|hotel_id|
            TripadvisorWorker.perform_async(hotel_id)
        }
        render json: {"message": "Fetching all ota's prices"}
    end

    def scraper_specific_hotel
        # TripadvisorWorker.perform_later(params["hotel_id"])
        TripadvisorWorker.perform_async(params["hotel_id"])
        render json: {"message": "Fetching ota's prices"}
    end
end
