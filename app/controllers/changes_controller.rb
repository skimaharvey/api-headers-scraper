class ChangesController < ApplicationController
    def last_changes 
        user = User.find(params["user_id"])
        competitors_hotels_ids = user.hotels.map{|hotelObj| hotelObj.id}
        user_hotel_id = user.hotel.id
        all_hotels_ids = competitors_hotels_ids.push(user_hotel_id) 

        all_reservations = []
        all_prices_changes = []

        all_hotels_ids.each{|hotel_id|
            hotel_reservations = NewReservation.where(hotel_id: hotel_id, created_at: 7.days.ago..Date.tomorrow)
            hotel_reservations.each{|reservation| all_reservations.push(reservation)}
            price_changes = NewPrice.where(hotel_id: hotel_id, created_at: 7.days.ago..Date.tomorrow)
            price_changes.each{|price_change| all_prices_changes.push(price_change)}
        }
        render json: {"new_reservations": all_reservations, "new_prices": all_prices_changes}
    end
end
