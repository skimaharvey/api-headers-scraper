class ScrapingSessionsController < ApplicationController

    def scraper_without_headers
        hotel_reservation_code = params["hotel_reservation_code"]
        hotel = Hotel.find_by(hotel_reservation_code: hotel_reservation_code)
        reservation_manager_name = ReservationManager.find(hotel.reservation_manager_id).name
        case reservation_manager_name
            when 'reservit'
                #send request to django header scraper
                HTTParty.post('https://scrapthem.com/scraper/', 
                :body => { "hotel_id": hotel_reservation_code, "hotel_name": hotel.name},
                )
                render json: {"message": "#{hotel.name} headers were fetched"}, status: 200
        end
    end

    def scraper_with_headers
        hotel_reservation_code = params["hotel_reservation_code"]
        authorization_code = params["authorization_code"]
        cookie = params["cookie"]
        hotel = Hotel.find_by(hotel_reservation_code: hotel_reservation_code)
        reservation_manager_name = ReservationManager.find(hotel.reservation_manager_id).name
        case reservation_manager_name
            when 'reservit'
                ReservitScraper.launch_scraper(hotel_reservation_code, 
                authorization_code, cookie)
                # ReservitScraper.test 
                render json: {"message": "#{hotel.name} was successfully updated"}, status: 200
        end
    end
end
