class TripadvisorWorker
  include Sidekiq::Worker

  def request_body_converter(request_body, date, formatted_date)
    checkin_date = date.strftime("%Y_%m_%d")
    checkout_date = date.advance(days: 1).strftime("%Y_%m_%d")
    date_first_occurence_index = request_body.index(formatted_date)
    original_date_plus_one = request_body[date_first_occurence_index + 11 .. date_first_occurence_index + 20]
    checkout_to_replace = request_body.index(checkin_date)
    new_request_body = request_body.gsub(formatted_date, checkin_date)
    new_request_body.gsub(original_date_plus_one, checkout_date)
end

def perform(hotel_id)
    tripadvisor_request = TripadvisorRequest.where(hotel_id: hotel_id).last
    request_body = tripadvisor_request.request_body
    formatted_date = tripadvisor_request.date
    scraping_session = ScrapingSession.create!(date: Time.now, hotel_id: hotel_id, is_ota_type: true)
    DateOfPrice.for_the_next_90_days
    all_dates = DateOfPrice.where('date >= ?', Date.today ).first(89)
    post_url = 'https://www.tripadvisor.com/data/1.0/batch'
    
    eur_usd_rate = HTTParty.get('http://data.fixer.io/api/latest?access_key=b2df67f2dec3a8ff428771e2df049519')

    eur_usd_rate = eur_usd_rate["rates"]["USD"]
    all_dates.each{|dateObj|
        # begin
            formatted_request_body = request_body_converter(request_body, dateObj.date, formatted_date)
            complete_response = false
            counter = 0
            date_of_price_id = dateObj.id
            #TODO FETCH API THAT RANDOMIZES PROXY
            HTTParty::Basement.http_proxy('107.150.65.166', 7777, 'maxvia', '141614')
            
            while !complete_response && counter < 5
                puts("fetching availabilities for: #{dateObj.date.to_s}, hotel_id: #{hotel_id}")
                # puts(formatted_request_body)
                response = HTTParty.post(post_url, 
                    :body => formatted_request_body,
                    :headers => {"content-type": "application/json"}
                )
                # puts(response)
                response_status = response.keys.select{|key| key.include?("fields_complete_")}[0]
                # puts (response_status)
                response_body = response.keys.select{|key| key.include?("chevronOffers_complete_hiddenOffers_textLinkOffers_urgencyAlert_offerFields_data_status")}[0]
                # puts (response_body)
                if response[response_status].values[0]["body"]["complete"] == true
                    complete_response = true
                    all_offers = response[response_body].values[0]["body"]["textLinkOffers"]
                    offers_prices = []
                    all_offers.each{|offerObj|
                        if offerObj["status"] == "AVAILABLE"
                            ota_name = offerObj["data"]["provider"]
                            perNight = offerObj["data"]["dataAtts"]["data-perNight"].to_i
                            tax = offerObj["data"]["dataAtts"]["data-taxesValue"].to_i 
                            price = tax + perNight 
                            offers_prices << { "price": price, "provider": ota_name}
                        end
                    }
                    if offers_prices.length > 0
                        all_prices = offers_prices.map{|offer|
                            offer[:price]
                        }
                        mini_price = all_prices.min / eur_usd_rate
                        best_offer = offers_prices.select {|obj| obj[:price] == mini_price }[0]
                        OtaPrice.create!(date_of_price_id: date_of_price_id, price: mini_price, 
                            hotel_id: hotel_id, provider: best_offer[:provider], available: true,
                            scraping_session_id: scraping_session.id
                        )  
                    else 
                        OtaPrice.create!(date_of_price_id: date_of_price_id, price: 0, 
                        hotel_id: hotel_id, provider: "none", available: false,
                        scraping_session_id: scraping_session.id
                    )                           
                    end
                end
                sleep 3
                counter += 1
            end
        # rescue => e
        #     print('ERROR IN OTA SCRAPING')
        #     ScrapingError.create(hotel_id: hotel_id, scraping_session_id:
        #     scraping_session.id, price_type_ota: true, error: e, date_of_price_id:
        #     dateObj.id, response: response
        #     )
            # next
        # end
    }
end
end
