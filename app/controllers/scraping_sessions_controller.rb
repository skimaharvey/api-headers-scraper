class ScrapingSessionsController < ApplicationController

    def launch_competitors_scraper 
        #scrape competitors hotel + user hotel 
        UserHotelsScraperWorker.perform_async(params["user_id"])
        render json: {"message": "Scrapers starting"}
    end

    #this is the method that is called when we dont have the appropriate headers in order to make the calls
    def scraper_without_headers
        hotel_id = params["hotel_id"]
        hotel = Hotel.find(hotel_id)
        reservation_manager_name = ReservationManager.find(hotel.reservation_manager_id).name
        case reservation_manager_name
            when 'reservit'
                #send request to django header scraper
                hotel_reservation_code = hotel.hotel_reservation_code
                begin
                    response = HTTParty.post('https://django-scraper.caprover.scrapthem.com/scraper/', 
                    :body => { "hotel_id": hotel_id, "hotel_name": hotel.name,
                        "hotel_reservation_code": hotel_reservation_code},
                    )  
                    render json: {"message": "#{hotel.name} headers are going to be fetched"}, status: 200  
                rescue
                    ScrapingError.create(error: "error when fetching the reservit headers", hotel_id: hotel_id)
                end   
            when "availpro"
                #TODO MAKE A SMALL PYTHON API THAT WILL GET THE HEADERS INFOS
                verification_token = 'XCcHwTI90iFQWqKPL_HDTklGdTZQGn_tevHDaksEtECd0NY-jYtH9iaUQg5TbbU-mSC3t2LFcq_UyzKM6YdPhBEya8eN_Bq273kgAsjleRo1'
                # clos_url = "https://www.secure-hotel-booking.com/smart/Le-Clos-d-Amboise/24Y6/en/Room/CheckAvailability"
                cookie =  '__RequestVerificationToken_L3NtYXJ00=b5IcD6KP4D6r9qLL-nqN1n8fVkgW5gv9bNCph0UcW4murOFktiD6ptqSHa8qTlJtleosjnOH3aG5-9Dii_4drN6L63MGWcdBmsAbPYGlmQg1; _gid=GA1.2.1953277223.1615054743; hdb_uid=01f2847d60a0def3bda6c5c7c1db365b; user_ip=138.199.47.149; PageCount=10; _ga=GA1.2.1137562290.1615054743; _ga_MCT4PKC8C8=GS1.1.1615061472.2.0.1615061472.60; availpro.be.applicationVersion=4.19.1.61495'
                AvailproWorker.perform_async(hotel_id, hotel.reservation_url, verification_token, cookie)
        end
    end

    #this is the method that django scraper will call once it has fetched the appropriate headers
    def scraper_with_headers
        hotel_reservation_code = params["hotel_reservation_code"]
        hotel_id = params["hotel_id"]
        authorization_code = params["authorization_code"]
        cookie = params["cookie"]
        hotel = Hotel.find(hotel_id)
        reservation_manager_name = ReservationManager.find(hotel.reservation_manager_id).name
        case reservation_manager_name
            when 'reservit'
                #ReservitJob.perform_later(hotel_reservation_code, hotel_id, authorization_code, cookie)
                ReservitWorker.perform_async(hotel_reservation_code, hotel_id, authorization_code, cookie)
            when 'synxis'
                #ReservitJob.perform_later(hotel_reservation_code, hotel_id, authorization_code, cookie)
                SynxisWorker.perform_async(hotel_id, cookie)
        end
        render json: {"message": "Scraper starting"}
    end

    def scrape_specific_hotel
        hotel = Hotel.find(params["hotel_id"])
        reservation_manager_name = ReservationManager.find(hotel.reservation_manager_id).name
        case reservation_manager_name
            when 'reservit'
                #send request to django header scraper in order to get the requests
                hotel_reservation_code = hotel.hotel_reservation_code
                begin
                HTTParty.post('https://django-scraper.caprover.scrapthem.com/scraper/', 
                :body => { "hotel_id": hotel.id, "hotel_name": hotel.name,
                    "hotel_reservation_code": hotel.hotel_reservation_code},
                )
                rescue
                ScrapingError.create(error: "error when fetching the reservit headers", hotel_id: hotel.id)
                end
                # render json: {"message": "#{hotel.name} headers were fetched"}, status: 200
            when "availpro"
                #TODO MAKE A SMALL PYTHON API THAT WILL GET THE HEADERS INFOS
                verification_token = 'XCcHwTI90iFQWqKPL_HDTklGdTZQGn_tevHDaksEtECd0NY-jYtH9iaUQg5TbbU-mSC3t2LFcq_UyzKM6YdPhBEya8eN_Bq273kgAsjleRo1'
                # clos_url = "https://www.secure-hotel-booking.com/smart/Le-Clos-d-Amboise/24Y6/en/Room/CheckAvailability"
                cookie =  '__RequestVerificationToken_L3NtYXJ00=b5IcD6KP4D6r9qLL-nqN1n8fVkgW5gv9bNCph0UcW4murOFktiD6ptqSHa8qTlJtleosjnOH3aG5-9Dii_4drN6L63MGWcdBmsAbPYGlmQg1; _gid=GA1.2.1953277223.1615054743; hdb_uid=01f2847d60a0def3bda6c5c7c1db365b; user_ip=138.199.47.149; PageCount=10; _ga=GA1.2.1137562290.1615054743; _ga_MCT4PKC8C8=GS1.1.1615061472.2.0.1615061472.60; availpro.be.applicationVersion=4.19.1.61495'
                AvailproWorker.perform_async(hotel.id, hotel.reservation_url, verification_token, cookie)
            when "synxis"
                #TODO MAKE A SMALL PYTHON API THAT WILL GET THE HEADERS INFOS
                synxis_att = SynxisHelper.find_by(hotel_id: params["hotel_id"])
                hotel_chain = synxis_att.chain_ref
                hotel_ref = synxis_att.hotel_ref
                response = HTTParty.post('https://django-scraper.caprover.scrapthem.com/scraper_synxis_async/', 
                :body => { :hotel_chain => hotel_chain, 
                        :hotel_id => hotel_ref, 
                        :rails_hotel_id => hotel.id, 
                        }
                )
        end
        render json: {"message": "Scraper starting"}

    end
end
