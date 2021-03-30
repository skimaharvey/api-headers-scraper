class ReservitJob < ApplicationJob
  queue_as :default

  def perform(hotel_reservation_code, hotel_id, authorization_code, cookie)
      ReservitScraper.launch_scraper(hotel_reservation_code, 
      authorization_code, cookie, hotel_id)
  end
end
