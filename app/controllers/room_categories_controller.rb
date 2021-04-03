class RoomCategoriesController < ApplicationController
    def room_categories_list
        user_id = params['user_id']
        user_hotel = User.find(user_id).hotel
        user_hotel_rooms = user_hotel.room_categories
        competitors_rooms = User.find(user_id).hotels.map{|hotel_obj|
            hotel_obj.room_categories
        }
        room_equivalences = user_hotel_rooms.map{|room|
            room.room_equivalences
        }
        render json: {
            "user_hotel_rooms": user_hotel_rooms, 
            "competitors_rooms": competitors_rooms, 
            "room_equivalences": room_equivalences
        }
    end
end
