class TripadvisorRequestsController < ApplicationController
    def create
        trip = TripadvisorRequest.new(
            hotel_name: params["hotel_name"],
            proxy: params["proxy"],
            hotel_id: params["hotel_id"],
            request_body: params['request_body'],
            date: params["date"]
        )
        if trip.save
            render json: {"message": "Tripadvisor request created"}, status: 200
        else
            render json: {"error": "Error while saving"}, status: 500
        end
    end

    def fetch_all_user_otas 
        user_id = params["user_id"]
        competitors_ids = HotelCompetitor.where(user_id: user_id).map{|hc|
            hc.hotel_id
        }
        user_hotel_id = HotelOwner.find_by(user_id: user_id).hotel_id
        all_ids = competitors_ids.push(user_hotel_id)
        all_ids.each{|hotel_id|
            TripadvisorWorker.perform_async(hotel_id)
        }
        render json: {"message": "Fetching Ota's prices started"}, status: 200
    end

    def fetch_specific_hotel_ota 
        TripadvisorWorker.perform_async(params['hotel_id'])
    end
end
