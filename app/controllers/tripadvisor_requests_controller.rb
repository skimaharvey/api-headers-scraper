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
end
