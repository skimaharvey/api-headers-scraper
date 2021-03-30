class ReservitJobJob < ApplicationJob
  queue_as :default

  def perform(hotel_reservation_code, hotel_id, authorization_code, cookie)
    hotel = Hotel.find(hotel_id)
    reservation_manager_name = ReservationManager.find(hotel.reservation_manager_id).name
    case reservation_manager_name
        when 'reservit'
            ReservitScraper.launch_scraper(hotel_reservation_code, 
            authorization_code, cookie, hotel_id)
            # ReservitScraper.test 
            render json: {"message": "#{hotel.name} was successfully updated"}, status: 200
    end
  end
end
