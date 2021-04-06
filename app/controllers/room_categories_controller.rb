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

    def fetch_rooms_equivalences 
        all_rooms_ids = params["allRoomsIds"]
        tempHash = {}
        all_equivalences = []
        
        all_rooms_ids.map{|id|
            price_equivalence = RoomCategory.find(id).price_equivalence
            room_equivalence = RoomCategory.find(id).room_equivalence
            tempHash[id] = {"price_equivalence" => price_equivalence, "room_equivalence" => room_equivalence}
            all_equivalences.push(tempHash)
        }
        render json: {"rooms_equivalences": tempHash}, status: 200
    end
end
