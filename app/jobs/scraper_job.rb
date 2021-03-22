class ScraperJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    # Do something later
    competitors_ids = HotelCompetitor.where(user_id: user_id).map{|hc|
        hc.hotel_id
    }
    user_hotel_id = Hotel.find_by(user_id: user_id).id
    all_ids = competitors_ids.push(user_hotel_id)
    all_ids.each{|hotel_id|
        hotel = Hotel.find(hotel_id)
        reservation_manager_name = ReservationManager.find(hotel.reservation_manager_id).name
        case reservation_manager_name
            when 'reservit'
                #send request to django header scraper in order to get the requests
                hotel_reservation_code = hotel.hotel_reservation_code
                HTTParty.post('https://scrapthem.com/scraper/', 
                :body => { "hotel_id": hotel_id, "hotel_name": hotel.name,
                    "hotel_reservation_code": hotel.hotel_reservation_code},
                )
                # render json: {"message": "#{hotel.name} headers were fetched"}, status: 200
            when "availpro"
                #TODO MAKE A SMALL PYTHON API THAT WILL GET THE HEADERS INFOS
                verification_token = 'XCcHwTI90iFQWqKPL_HDTklGdTZQGn_tevHDaksEtECd0NY-jYtH9iaUQg5TbbU-mSC3t2LFcq_UyzKM6YdPhBEya8eN_Bq273kgAsjleRo1'
                # clos_url = "https://www.secure-hotel-booking.com/smart/Le-Clos-d-Amboise/24Y6/en/Room/CheckAvailability"
                cookie =  '__RequestVerificationToken_L3NtYXJ00=b5IcD6KP4D6r9qLL-nqN1n8fVkgW5gv9bNCph0UcW4murOFktiD6ptqSHa8qTlJtleosjnOH3aG5-9Dii_4drN6L63MGWcdBmsAbPYGlmQg1; _gid=GA1.2.1953277223.1615054743; hdb_uid=01f2847d60a0def3bda6c5c7c1db365b; user_ip=138.199.47.149; PageCount=10; _ga=GA1.2.1137562290.1615054743; _ga_MCT4PKC8C8=GS1.1.1615061472.2.0.1615061472.60; availpro.be.applicationVersion=4.19.1.61495'
                ScraperAvailpro.launch_scraper(hotel_id, hotel.reservation_url, verification_token, cookie)
        end
    }
  end
end
