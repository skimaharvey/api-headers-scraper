class HotelsController < ApplicationController

    def create 
        begin
        @hotel = Hotel.create(name: params["name"], hotel_reservation_code: params["hotel_reservation_code"])
        render json: {"hotel_id": @hotel}, status: 200
        rescue => error
            render json: {"message", error}, status: 400
        end
    end
end
