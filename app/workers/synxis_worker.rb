class SynxisWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def modify_body_request(checkin_date, checkout_date, initial_body)
    initial_body[:ProductAvailabilityQuery][:RoomStay][:StartDate] = checkin_date
    initial_body[:ProductAvailabilityQuery][:RoomStay][:EndDate] = checkout_date
    initial_body
  end
  #TODO CREATE TWO OBJECTS AND COMPARE TO SEE WHAT ARE THE NEW RESERVATION ETC...

  def check_last_scraping_differences(new_scraping_id, hotel_id)
    last_scraping_session = ScrapingSession.where(hotel_id: hotel_id, is_complete: true).where.not(id: new_scraping_id)
    if last_scraping_session.length > 0 
        @last_scraping_session_id = last_scraping_session.last.id
    end
    all_prices = Price.where(scraping_session_id: @last_scraping_session_id)
    @last_prices_objs = {}
    all_prices.each{|priceObj|
        @last_prices_objs["#{priceObj.date_of_price_id}-#{priceObj.room_category_id}"] = 
            {"price": priceObj.price, "n_of_units_available": priceObj.n_of_units_available,
             "room_category_id": priceObj.room_category_id, "date_of_price_id": priceObj.date_of_price_id,
            }  
    }

    @new_prices_objs.keys.each{|date_roomid|
        if @new_prices_objs.key?(date_roomid) && @last_prices_objs.key?(date_roomid)
            #change in n_of_units available
            if @new_prices_objs[date_roomid][:n_of_units_available] != @last_prices_objs[date_roomid][:n_of_units_available] 
                NewReservation.create!(hotel_id: hotel_id, 
                    room_category_id: @last_prices_objs[date_roomid][:room_category_id],
                    date_of_price_id: @last_prices_objs[date_roomid][:date_of_price_id],
                    price: @last_prices_objs[date_roomid][:price]? @last_prices_objs[date_roomid][:price] : @new_prices_objs[date_roomid][:price],
                    n_units: @last_prices_objs[date_roomid][:n_of_units_available] - @new_prices_objs[date_roomid][:n_of_units_available]
                )
            end
            #change in price 
            if @new_prices_objs[date_roomid][:price] != @last_prices_objs[date_roomid][:price] && @new_prices_objs[date_roomid][:price] != -1 && @last_prices_objs[date_roomid][:price] != -1
                NewPrice.create!(hotel_id: hotel_id, 
                    room_category_id: @last_prices_objs[date_roomid][:room_category_id],
                    date_of_price_id: @last_prices_objs[date_roomid][:date_of_price_id],
                    old_price: @last_prices_objs[date_roomid][:price],
                    new_price: @new_prices_objs[date_roomid][:price],
                    n_units: @new_prices_objs[date_roomid][:n_of_units_available]
                )
            end
        end
    }

  end

  def perform(hotel_id, synxis_cookie)
    hotel = Hotel.find(hotel_id)
    synxis_att = SynxisHelper.find_by(hotel_id: hotel_id)
    
    @new_prices_objs = {}

    scraping_session = ScrapingSession.create(is_ota_type: false, hotel_id: hotel_id)
    scraping_session_id = scraping_session.id
    url = synxis_att.url
    initial_body_request = synxis_att.body_request
    proxies = ['107.150.65.179', '209.58.157.45', '107.150.64.7', '191.102.167.205', '107.150.65.166',
    '191.102.167.239', '107.150.64.25', '191.102.167.102', '209.58.157.66', '191.102.167.55'
    ]
    # url  = synxis_att.url 
    new_proxy = proxies.sample
    puts synxis_cookie
    # synxis_cookie =  "visid_incap_1215874=zmwMYOYQQ62EPa7Ju6b0piyeeWAAAAAAQUIPAAAAAABmfCa4Czk75Jm5h/83fJAn; incap_ses_1362_1215874=VSxPMihrOg/ruFTG5MvmEiyeeWAAAAAAXiz1mXPEUYjG23u1uiOs0Q==; sessionID=4bFWBFXEpjh0fBdQfy7tqpGc; apisession=MDAxMTZ-SXpxT1U4cjREK05HNlVDQjd3UnoweitHQ1dJSjNyd0hyOTlaRS9UdGtIK05KVlBrbDNHSjFmTnNBTnFudld6VVNydmN6Z1dRR2d0V1RTSXpMMFc1V3FiaE5IK3EzTnluMGRRZlhpdkRlZ1dqaGQ5YnJnWUtEMjFlTWN3SkwzZGE2SzBuRURmQ1hFQ1BLZUt0WVV5cE5uTzR0Rmc2WEVWQ3JxK3lFRWJEdkZDL2lpMXRJbGxKcm9mNm5ReUhmbmNNUDErMUxNQUs5VWZEOWFpakM2YVl3YzFUY09aM25ZeWVTejF4akdWc0hoWUNVLzdEM0ROT2RQcGZtZDdDK3YxMjYzNzdPbldpYUFrck14Z3JyZGhKRmlhbWw1VmFQb1g1V2JKL3UrTG5RYWw4WnM4TU1jbWloc01tMzEydXdIQ0c; nlbi_1215874=1z5BHjfcZ2lxJoFQnAADWwAAAAAf+i6LsIVe6JR6q/IA2HMM"

    all_dates = DateOfPrice.where('date >= ?', Date.today ).first(30)
    dates_arr = []
    dates_plus_one_arr = []
    all_dates.each {|date|
        dates_arr << {"date": date.date.strftime("%Y-%m-%d"), "id": date.id }
        dates_plus_one_arr << date.date.next_day(1).strftime("%Y-%m-%d")
    }
    hotel_rooms_obj = {}
    @hotel_rooms = RoomCategory.where(hotel_id: hotel_id).map{|room_cat| 
      hotel_rooms_obj[room_cat.name] = room_cat.id
      room_cat.name
    }
    max_retries = 2
    HTTParty::Basement.http_proxy(new_proxy, 7777, 'maxvia', '141614')
    dates_arr.each_with_index{|date, index|
        times_retried = 0
        body_request = modify_body_request(date[:date], dates_plus_one_arr[index], initial_body_request)
        begin 
        # new_proxy = proxies.sample
        sleep (1..6).to_a.sample
        # HTTParty::Basement.http_proxy(new_proxy, 7777, 'maxvia', '141614')
        referer = "https://be.synxis.com/?_submit=18/04/2021&adult=1&arrive=2021-04-18&chain=18985&child=0&config=CHAIN_CONFIGS&currency=EUR&depart=2021-04-19&etabIdQS=18985&fday=18&fmonth=04&fyear=2021&hotel=68208&level=hotel&locale=en-US&rooms=1&shell=ResponsiveShared&start=availresults&tday=19&template=ResponsiveShared&tmonth=04&tyear=2021"
        response = HTTParty.post(url, 
            :body => body_request.to_json,
            :headers => { 'content-type' =>  'application/json; charset=UTF-8',
                          'Conversation-ID' => '1spskcg4k',
                          'cookie' => synxis_cookie,
                          "origin" => "https://be.synxis.com", 
                          # "Set-Cookie" =>"apisession=MDAxMTZ-cVd4aFVCSkM1cmRjYTJ2WWZmc1dUNUhOTnNMeThNN05SK05TV2U2alZSbHNlaGNBYmtkTHVFNkxFZkZnMmFyZGYxQ2RnNWZsdThKOHVGTlVDSUNWcHVoYVVDUGhNaXdTcVJ4bDMzU1lZM3JzZW5vYWlieVQwNDVxSE1uZVVSMFJGS0RZRGc2eG5JWVV2N1pBaFJsM0ZDV0Y0WFNhY2cwZk9DWlhiaDNiWlBWYVVPNE5hcEN4aHFnVCttSlV6TDJlUkRMRi9abmNUQ0FmeDFrWmUrY2NCejZVOTRvVzFNYmRtWlB1WUFYT1M4ZGEzaFg1V3FMZ0J5UVVNZllwUkxkb3JrdDlINjFNM0RBS2dzNzA5TEUzS1p1S1JKbWphMnd1bjg5d1o3NzBLVU5QMjdUeElwbkd2UW9IVll0d3N6ay8; Domain=synxis.com; Path=/; HttpOnly; Secure",
                          'Host' => 'be.synxis.com',
                          'Cache-Control' => 'no-cache',
                          "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_0_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.128 Safari/537.36",
                          "referer" => referer,
                          "accept-encoding" => "gzip, deflate, br",
                          "context" => "BE",
                          "sec-ch-ua" => `Google Chrome";v="89", "Chromium";v="89", ";Not A Brand";v="99`,
                          "sec-fetch-mode" => "cors",
                          "sec-fetch-site" => "same-origin",
                          "x-business-context" => "BE"
                          # "Content-Length" => '76'
                       } 
        )
        # puts "good headers: #{response.headers}"
        product_status = response["ProductAvailabilityDetail"]["LeastRestrictiveFailure"]["ProductStatus"]
        if product_status == "NoAvailableInventory" 
            puts "fully booked on date id: #{date[:date]}"
            @hotel_rooms.each{|room_name|
              @new_prices_objs["#{date[:id]}-#{hotel_rooms_obj[room_name]}"] = {"price": -1, "n_of_units_available": 0}
              Price.create!(price: -1, available: false, n_of_units_available: 0, 
                hotel_id: hotel_id,
                date_of_price_id: date[:id], room_category_id: hotel_rooms_obj[room_name], 
                scraping_session_id: scraping_session_id
              )
            }
        elsif product_status == "MinStayArrive" || product_status == "Closed"
          #fetch all inventories per room cat
          puts 'responses is good'
          obj_cat_quantity = {}
          current_rooms = []
          prices_arr = response["ProductAvailabilityDetail"]["Prices"]
          rooms_prices_obj = {}
          prices_arr.each{|price_obj|
              all_prices = []
              all_inventories = []
              price_obj["Product"]["Prices"]["Daily"].each{|dailyObj|
                # price = dailyObj["Price"]["Total"]["Amount"]
                price = dailyObj['Price']["Amount"]
                inventory = dailyObj["AvailableInventory"]
                all_inventories.push(inventory)
                all_prices.push(price)
              }
              stock = all_inventories.max
              minimum_price = all_prices.min
              room_name = price_obj["Product"]["Room"]["Code"]
              n_units = price_obj["AvailableInventory"]
              room_id = hotel_rooms_obj[room_name]
              current_rooms.push(room_name)
              rooms_prices_obj[room_name] = minimum_price
              if rooms_prices_obj.key?(room_name.to_sym) || rooms_prices_obj.key?(room_name)
                if rooms_prices_obj[room_name] > minimum_price
                  @new_prices_objs["#{date[:id]}-#{hotel_rooms_obj[room_name]}"] = {"price": minimum_price, "n_of_units_available": stock}
                  price_to_update = Price.where(scraping_session_id:scraping_session_id, room_category_id:  hotel_rooms_obj[room_name],
                  date_of_price_id: date[:id]).last
                  price_to_update.update(price: minimum_price)
                end
              else
                @new_prices_objs["#{date[:id]}-#{hotel_rooms_obj[room_name]}"] = {"price": minimum_price, "n_of_units_available": stock}
                Price.create!(price: minimum_price, available: true, n_of_units_available: stock, 
                  hotel_id: hotel_id,
                  date_of_price_id: date[:id], room_category_id: hotel_rooms_obj[room_name], 
                  scraping_session_id: scraping_session_id
                )
              end
          }

          rooms_unavailable = @hotel_rooms - @hotel_rooms 

          if rooms_unavailable.length 
            rooms_unavailable.each{|room_name|
              @new_prices_objs["#{date[:id]}-#{hotel_rooms_obj[room_name]}"] = {"price": -1, "n_of_units_available": 0}
              Price.create!(price: -1, available: false, n_of_units_available: 0, hotel_id: hotel_id,
                date_of_price_id: date[:id], room_category_id: hotel_rooms_obj[room_name], 
                scraping_session_id: scraping_session_id
              )
            }
          end
        end
        
      rescue => error
        if times_retried < max_retries
          times_retried += 1
          puts "Failed to <do the thing>, retry #{times_retried}/#{max_retries}, proxy: #{new_proxy}, cookie: #{synxis_cookie}"
          puts "response headers: #{response.headers}"
          puts "--------------"
          puts error
          # proxies.delete(new_proxy)
          sleep 30
          retry
        else
          puts "ADD SPECIFIC DATE TO WORKER"
          break
          #   exit(1)
        end
      end
        sleep 1
    }
    scraping_session.update(is_complete: true)
    check_last_scraping_differences(scraping_session_id, hotel_id)
  end
end
