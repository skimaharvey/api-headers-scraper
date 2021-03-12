class HotelsController < ApplicationController

    def create 
        @hotel = Hotel.create(hotel_name: params["name"], hotel_reservation_code: params["hotel_reservation_code"])
        render json: {"hotel_id": @hotel}, status: 200
    end
end
