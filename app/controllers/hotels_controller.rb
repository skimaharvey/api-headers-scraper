class HotelsController < ApplicationController

    def create 
        begin
        @hotel = Hotel.create(
            name: params["name"], 
            hotel_reservation_code: params["hotel_reservation_code"],
            reservation_manager_id: params["reservation_manager_id"]
        )
        render json: {"hotel_id": @hotel}, status: 200
        rescue => error
            render json: {"message": error}, status: 400
        end
    end

    def update 
        hotel = Hotel.find(params["id"])
        if hotel.update(
                name: params["name"],
                hotel_reservation_code: params["hotel_reservation_code"],
                reservation_manager_id: params["reservation_manager_id"]
            )
            render json: {"message": "Success"}, status: 200
        else
            render json: {"message": "Failed"}, status: 200
        end
    end
end
