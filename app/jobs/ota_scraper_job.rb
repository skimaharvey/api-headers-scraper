class OtaScraperJob < ApplicationJob
  queue_as :default

  def perform(hotel_id)
    # Do something later
    # competitors_ids = HotelCompetitor.where(user_id: user_id).map{|hc|
    #     hc.hotel_id
    # }
    # user_hotel_id = Hotel.find_by(user_id: user_id).id
    # request_body = 
    # all_ids = competitors_ids.push(user_hotel_id)
    tripadvisor_obj = TripadvisorRequest.find_by(hotel_id: hotel_id)
    tripadvisor_request_body = tripadvisor_obj.request_body
    date_format = tripadvisor_obj.date
    OtaScraper.launch_scraper(hotel_id, tripadvisor_request_body, date_format)
    
  end
end
