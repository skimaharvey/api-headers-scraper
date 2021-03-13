class ScrapingSessionsController < ApplicationController
    def scrape_reservit
        hotel_reservation_code = params["hotel_reservation_code"]
        puts hotel_reservation_code
        authorization_code = params["authorization_code"]
        puts authorization_code
        cookie = params["cookie"]
        puts cookie
        hotel = Hotel.find_by(hotel_reservation_code: hotel_reservation_code)
        reservation_manager_name = ReservationManager.find(hotel.reservation_manager_id).name
        case reservation_manager_name
        when 'reservit'
            ReservitScraper.launch_scraper(hotel_reservation_code, 
            authorization_code, cookie)
            # ReservitScraper.test 
            render json: {"hotel_id": @hotel_id}, status: 200
        end

    end
end
