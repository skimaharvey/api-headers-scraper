class AvailproWorker
  include Sidekiq::Worker
#   sidekiq_options :retry => false
  
  def send_scraping_session_to_client(hotel_id)
    hotel = Hotel.find(hotel_id)
    last_session = ScrapingSession.where(hotel_id: hotel_id).last.id
    last_prices = Price.where(scraping_session_id: last_session)
    HotelsChannel.broadcast_to hotel, last_prices
  end

  def check_if_room_type_exits(room_code, room_name, hotel_id, quantity)
    if !@room_cats_ids.key?(room_code)
        new_room_cat = RoomCategory.create!(name: room_name, hotel_id: hotel_id, 
        room_code: room_code, number_of_units: quantity)
        room_id = new_room_cat.id
        @room_cats_ids[room_code] = room_id
    else 
        existing_room_cat = RoomCategory.where(room_code: room_code, hotel_id: hotel_id)[0]
        room_quantity = existing_room_cat.number_of_units
        if room_quantity < quantity
            existing_room_cat.update(number_of_units: quantity)
        end
    end
    #get the max quantity for a specific room category 
  end

  def perform(hotel_id, url, verification_token,cookie)
    # hotel_id = 2
    @room_cats_ids = {}
    @hotel = Hotel.find(hotel_id)
    @room_categories_arr = RoomCategory.where(hotel_id: hotel_id).each{|room_cat|
        @room_cats_ids[room_cat.room_code] = room_cat.id
        room_cat.room_code
    }
    scraping_session = ScrapingSession.create(hotel_id: hotel_id)
    all_dates = DateOfPrice.where('date >= ?', Date.today ).first(90)
    dates_arr = []
    dates_plus_one_arr = []
    all_dates.each {|date|
        dates_arr << {"date": date.date.strftime("%Y-%m-%d"), "id": date.id }
        dates_plus_one_arr << date.date.next_day(1).strftime("%Y-%m-%d")
    }

    proxies = ['107.150.65.179', '209.58.157.45', '107.150.64.7', '191.102.167.205', '107.150.65.166',
    '191.102.167.239', '107.150.64.25', '191.102.167.102', '209.58.157.66', '191.102.167.55'
    ]

    dates_arr.each_with_index{|date, index|
        max_retries = 3
        times_retried = 0
        begin
        HTTParty::Basement.http_proxy(proxies.sample, 7777, 'maxvia', '141614')
        response = HTTParty.post(url, 
            :body => { :checkinDate => date[:date], 
                    :checkoutDate => dates_plus_one_arr[index], 
                    :currency => 'EUR', 
                    },
            :headers => { '__RequestVerificationToken' =>  verification_token,
                        'Cookie' => cookie
                        } 
        )
        if response["success"] == false 
            puts "fully booked on date id: #{date[:date]}"
            @room_cats_ids.map{|key,value|
                new_price = Price.create!(price: -1, hotel_id: hotel_id, room_category_id: value,
                date_of_price_id: date[:id], n_of_units_available: 0, available: false, 
                scraping_session_id: scraping_session.id, ota_price: -1)
                # HotelsChannel.broadcast_to @hotel, new_price
            }
        else
            response["data"]["rooms"].map { |obj|
                room_id = @room_cats_ids[obj['roomId']].to_i
                room_name = @room_cats_ids[obj['name']]
                quantity = obj["rates"][0]["availability"].to_i
                check_if_room_type_exits(room_id, room_name, hotel_id, quantity)
                price = obj["rates"].map{|rateObj|
                        rateObj["price"].to_i
                        }.min
                puts "price: #{price}, room cat: #{room_id}"
                new_price = Price.create!(price: price, hotel_id: hotel_id, room_category_id: room_id,
                date_of_price_id: date[:id], n_of_units_available: quantity, available: true,
                scraping_session_id: scraping_session.id)
                # HotelsChannel.broadcast_to @hotel, new_price
            }
        end
        sleep 1
        rescue Net::ReadTimeout, Net::OpenTimeout, Errno::ECONNREFUSED, Errno::ECONNRESET => error
            if times_retried < max_retries
            times_retried += 1
            puts "Failed to <do the thing>, retry #{times_retried}/#{max_retries}"
            retry
            else
            puts "ADD SPECIFIC DATE TO WORKER"
            next
            #   exit(1)
            end
        end
    }
    send_scraping_session_to_client(hotel_id)
  end 
end
