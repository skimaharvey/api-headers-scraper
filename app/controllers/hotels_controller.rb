class HotelsController < ApplicationController

    def create 
        # begin
        @hotel = Hotel.create(
            name: params["name"], 
            hotel_reservation_code: params["hotel_reservation_code"],
            reservation_manager_id: params["reservation_manager_id"], 
            reservation_url: params['reservation_url']
        )
        #fetch and create room categories for the new hotel 
        reservation_manager_name = ReservationManager.find(@hotel.reservation_manager_id).name
        case reservation_manager_name
        when "availpro" 
            verification_token = 'XCcHwTI90iFQWqKPL_HDTklGdTZQGn_tevHDaksEtECd0NY-jYtH9iaUQg5TbbU-mSC3t2LFcq_UyzKM6YdPhBEya8eN_Bq273kgAsjleRo1'
            cookie =  '__RequestVerificationToken_L3NtYXJ00=b5IcD6KP4D6r9qLL-nqN1n8fVkgW5gv9bNCph0UcW4murOFktiD6ptqSHa8qTlJtleosjnOH3aG5-9Dii_4drN6L63MGWcdBmsAbPYGlmQg1; _gid=GA1.2.1953277223.1615054743; hdb_uid=01f2847d60a0def3bda6c5c7c1db365b; user_ip=138.199.47.149; PageCount=10; _ga=GA1.2.1137562290.1615054743; _ga_MCT4PKC8C8=GS1.1.1615061472.2.0.1615061472.60; availpro.be.applicationVersion=4.19.1.61495'
            #create rooms 
            AvailproCreateWorker.perform_async(@hotel.id, @hotel.reservation_url, verification_token, cookie)
            #fetch availabilities
            # AvailproWorker.perform(@hotel.id, @hotel.reservation_url, verification_token, cookie)
        when 'reservit'
            #TODO create api that just gets the correct headers 
            print "FETCHING HEADERS"
            # response = HTTParty.post('https://django-scraper.caprover.scrapthem.com/reservit_headers/', 
            #     :body => { :hotel_name => params["name"], 
            #             :hotel_reservation_code => params["hotel_reservation_code"], 
            #             :hotel_id => @hotel.id, 
            #             }
            # )
            # print response
            # authorization_code = response[:authorization_code]
            # cookie = response[:cookie]
            # authorization_code = "Bearer d150afd5ce4ecde24f83ab264ffd7485721fd2f4"
            # cookie = "JSESSIONID=0E4191AA9C594DC414A49A8FA5BB091D"
            # create rooms
            ReservitCreateWorker.perform_async(params["hotel_reservation_code"], authorization_code, cookie, @hotel.id)
            #fetch availabilities
            # ReservitWorker.perform_async(params["hotel_reservation_code"], authorization_code, cookie, @hotel.id)
        when 'synxis'
            #TODO CREATE PYTHON SCRAPER TO GET COOKIE BACK AND HAVE PYTHON SCRAPER MAKE A POST REQUEST TO RAILS API
            SynxisHelper.create(hotel_id: @hotel.id, chain_ref: params['hotel_chain'], hotel_ref: params['hotel_ref'])
            SynxisCreateWorker.perform_async(params['hotel_chain'], params['hotel_ref'], @hotel.id)
        end
        render json: {"hotel_id": @hotel}, status: 200
        # rescue => error
        #     render json: {"message": error}, status: 400
        # end
    end

    def update 
        hotel = Hotel.find(params["id"])
        if hotel.update(
                name: params["name"],
                hotel_reservation_code: params["hotel_reservation_code"],
                reservation_manager_id: params["reservation_manager_id"]
            )
            render json: {"message": "Success"}, status: 200
        else
            render json: {"message": "Failed"}, status: 200
        end
    end
end
