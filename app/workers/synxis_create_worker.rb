class SynxisCreateWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def modify_body_request(checkin_date, checkout_date, initial_body)
    initial_body[:ProductAvailabilityQuery][:RoomStay][:StartDate] = checkin_date
    initial_body[:ProductAvailabilityQuery][:RoomStay][:EndDate] = checkout_date
    initial_body
  end


  def perform(synxis_chain, synxis_id, hotel_id)
    hotel = Hotel.find(hotel_id)
    synxis_att = SynxisHelper.find_by(hotel_id: hotel_id)
    hotel_chain = synxis_chain
    hotel_ref = synxis_id
    url = synxis_att.url
    initial_body_request = synxis_att.body_request
    proxies = ['107.150.65.179', '209.58.157.45', '107.150.64.7', '191.102.167.205', '107.150.65.166',
    '191.102.167.239', '107.150.64.25', '191.102.167.102', '209.58.157.66', '191.102.167.55'
    ]
    response = HTTParty.post('https://django-scraper.caprover.scrapthem.com/scraper_synxis/', 
    :body => { :hotel_chain => hotel_chain, 
            :hotel_id => hotel_ref, 
            :rails_hotel_id => hotel.id, 
            }
    )
    # url  = synxis_att.url 
    puts "hotel chain: #{hotel_chain}, hotel_ref: #{hotel_ref}"
    puts "cookie"
    synxis_cookie = response["cookie"]
    puts synxis_cookie
    # synxis_cookie =  "visid_incap_1215874=zmwMYOYQQ62EPa7Ju6b0piyeeWAAAAAAQUIPAAAAAABmfCa4Czk75Jm5h/83fJAn; incap_ses_1362_1215874=VSxPMihrOg/ruFTG5MvmEiyeeWAAAAAAXiz1mXPEUYjG23u1uiOs0Q==; sessionID=4bFWBFXEpjh0fBdQfy7tqpGc; apisession=MDAxMTZ-SXpxT1U4cjREK05HNlVDQjd3UnoweitHQ1dJSjNyd0hyOTlaRS9UdGtIK05KVlBrbDNHSjFmTnNBTnFudld6VVNydmN6Z1dRR2d0V1RTSXpMMFc1V3FiaE5IK3EzTnluMGRRZlhpdkRlZ1dqaGQ5YnJnWUtEMjFlTWN3SkwzZGE2SzBuRURmQ1hFQ1BLZUt0WVV5cE5uTzR0Rmc2WEVWQ3JxK3lFRWJEdkZDL2lpMXRJbGxKcm9mNm5ReUhmbmNNUDErMUxNQUs5VWZEOWFpakM2YVl3YzFUY09aM25ZeWVTejF4akdWc0hoWUNVLzdEM0ROT2RQcGZtZDdDK3YxMjYzNzdPbldpYUFrck14Z3JyZGhKRmlhbWw1VmFQb1g1V2JKL3UrTG5RYWw4WnM4TU1jbWloc01tMzEydXdIQ0c; nlbi_1215874=1z5BHjfcZ2lxJoFQnAADWwAAAAAf+i6LsIVe6JR6q/IA2HMM"

    all_dates = DateOfPrice.where('date >= ?', Date.today ).first(60)
    dates_arr = []
    dates_plus_one_arr = []
    all_dates.each {|date|
        dates_arr << {"date": date.date.strftime("%Y-%m-%d"), "id": date.id }
        dates_plus_one_arr << date.date.next_day(1).strftime("%Y-%m-%d")
    }
    @hotel_rooms = []
    max_retries = 3
    dates_arr.each_with_index{|date, index|
        times_retried = 0
        body_request = modify_body_request(date[:date], dates_plus_one_arr[index], initial_body_request)
        begin 
        sleep (1..6).to_a.sample
        HTTParty::Basement.http_proxy(proxies.sample, 7777, 'maxvia', '141614')
        response = HTTParty.post(url, 
            :body => body_request.to_json,
            :headers => { 'Content-Type' =>  'application/json;charset=UTF-8',
                          'Conversation-ID' => '1spskcg4k',
                          'cookie' => synxis_cookie,
                          # "Set-Cookie" =>"apisession=MDAxMTZ-cVd4aFVCSkM1cmRjYTJ2WWZmc1dUNUhOTnNMeThNN05SK05TV2U2alZSbHNlaGNBYmtkTHVFNkxFZkZnMmFyZGYxQ2RnNWZsdThKOHVGTlVDSUNWcHVoYVVDUGhNaXdTcVJ4bDMzU1lZM3JzZW5vYWlieVQwNDVxSE1uZVVSMFJGS0RZRGc2eG5JWVV2N1pBaFJsM0ZDV0Y0WFNhY2cwZk9DWlhiaDNiWlBWYVVPNE5hcEN4aHFnVCttSlV6TDJlUkRMRi9abmNUQ0FmeDFrWmUrY2NCejZVOTRvVzFNYmRtWlB1WUFYT1M4ZGEzaFg1V3FMZ0J5UVVNZllwUkxkb3JrdDlINjFNM0RBS2dzNzA5TEUzS1p1S1JKbWphMnd1bjg5d1o3NzBLVU5QMjdUeElwbkd2UW9IVll0d3N6ay8; Domain=synxis.com; Path=/; HttpOnly; Secure",
                          'Host' => 'be.synxis.com',
                          'Cache-Control' => 'no-cache',
                          "User-Agent" => "Mozilla/5.0 (Windows NT 5.1) AppleWebKit/5312 (KHTML, like Gecko) Chrome/40.0.863.0 Mobile Safari/5312",
                          # "Content-Length" => '76'
                       } 
        )
        puts response
        product_status = response["ProductAvailabilityDetail"]["LeastRestrictiveFailure"]["ProductStatus"]
        if product_status == "NoAvailableInventory" 
            puts "fully booked on date id: #{date[:date]}"
        elsif product_status == "MinStayArrive" || product_status == "Closed"
          #fetch all inventories per room cat
          puts 'responses is good'
          obj_cat_quantity = {}
          prices_arr = response["ProductAvailabilityDetail"]["Prices"]
          prices_arr.each{|price_obj|
              # all_prices = []
              # price_obj["Product"]["Prices"]["Daily"].map{|dailyObj|
              #   # price = dailyObj["Price"]["Total"]["Amount"]
              #   obj_cat_price[]
              #   inventory = dailyObj["AvailableInventory"]
              #   all_quantities.push(inventory)
              # }
              room_code = price_obj["Product"]["Room"]["Code"]
              inventory = price_obj["AvailableInventory"]
              obj_cat_quantity[room_code] = inventory
            # if obj_cat_quantity[room_code].key?
            #   if obj_cat_quantity[room_code] < inventory
            #     obj_cat_quantity[room_code] = inventory
            #   end
            # else 
            #   obj_cat_quantity[room_code] = inventory 
            # end
          }
          roomsList = response["ContentLists"]["RoomList"]
          roomsList.each{|room_obj|
            code = room_obj["Code"]
            room_name = room_obj["Name"]
            size = room_obj["Details"]["Size"]["Max"]
            max_capacity = room_obj["Details"]["GuestLimit"]["Value"]

            if !@hotel_rooms.any? {|h| h.name == code}
              new_room  = RoomCategory.create(hotel_id: hotel_id, name: code,
              size: size, max_capacity: max_capacity, room_type_name: room_name, 
              number_of_units: obj_cat_quantity[code]
              )
              @hotel_rooms.push(new_room)
            else 
              obj = @hotel_rooms.select {|h| h.name == code}[-1]
              #check if room iventory < new inventory
              if obj.number_of_units < obj_cat_quantity[code]
                obj.number_of_units = obj_cat_quantity[code]
                RoomCategory.where(hotel_id: hotel_id, name: code).last.update(
                  number_of_units: obj_cat_quantity[code]
                )
              end
            end
          }
        else  
          sleep 2
          puts "couldnt scrape synxis hotel"
        end
      rescue => error
        if times_retried < max_retries
          times_retried += 1
          puts "Failed to <do the thing>, retry #{times_retried}/#{max_retries}"
          sleep 30
          retry
          else
          puts error
          puts "ADD SPECIFIC DATE TO WORKER"
          #   exit(1)
        end
      end
        sleep 1
    }
    SynxisWorker.perform_async(hotel_id, synxis_cookie)
  end
end
