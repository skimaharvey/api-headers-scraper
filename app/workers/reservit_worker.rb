class ReservitWorker
  include Sidekiq::Worker
#   sidekiq_options :retry => false

    def check_if_room_type_exits(room_code, room_name, room_type_name)
        if @room_categories_arr.include? room_code
        @room_id = @room_categories.select{|room_obj|
            room_obj["code"] == room_code 
        }[0]['id']
        @room_id
        else 
            new_room_cat = RoomCategory.create!(name: room_name, hotel_id: @hotel_id, 
            room_code: room_code, number_of_units: @n_units, room_type_name: room_type_name)
            @room_id = new_room_cat.id
        end
    end

    def check_last_scraping_differences(new_scraping_id, hotel_id)
        last_scraping_session = ScrapingSession.where(hotel_id: hotel_id, is_complete: true).where.not(id: new_scraping_id).sort_by(&:created_at)    
        if last_scraping_session.length > 0 
            @last_scraping_session_id = last_scraping_session.last.id
        end
        all_prices = Price.where(scraping_session_id: @last_scraping_session_id)
        @last_prices_objs = {}
        all_prices.each{|priceObj|
            @last_prices_objs["#{priceObj.date_of_price_id}-#{priceObj.room_category_id}"] = 
                {"price": priceObj.price, "n_of_units_available": priceObj.n_of_units_available,
                 "room_category_id": priceObj.room_category_id, 
                 "date_of_price_id": priceObj.date_of_price_id,
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
                        n_units: @last_prices_objs[date_roomid][:n_of_units_available] - @new_prices_objs[date_roomid][:n_of_units_available],
                        scraping_session_id: new_scraping_id, scraping_comparaison_id:  @last_scraping_session_id
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

    def check_if_room_type_already_recorded(date_id)
        #some rooms have more than one price (for example triple rooms) but we just want the cheapest option
        price_for_room_code = Price.where(scraping_session_id: @scraping_session.id, hotel_id: 
            @hotel_id, room_category_id: @room_id,  date_of_price_id: date_id
        )
        if price_for_room_code.present?
            if price_for_room_code[0].price > @price 
                price_for_room_code[0].update(price: @price)
            end
        else
            @new_prices_objs["#{date_id}-#{@room_id}"] = {"price": @price, "n_of_units_available": @n_units}
            new_price = Price.create!(price: @price, hotel_id: @hotel_id, room_category_id: @room_id, n_of_units_available: @n_units,
            date_of_price_id: date_id, scraping_session_id: @scraping_session.id, available: true
            )
            # HotelsChannel.broadcast_to @hotel, new_price
        end
    end

    def send_scraping_session_to_client(hotel_id)
    last_session = ScrapingSession.where(hotel_id: hotel_id).last.id
    last_prices = Price.where(scraping_session_id: last_session)
    HotelsChannel.broadcast_to @hotel, last_prices
    end

  def perform(hotel_reservation_code, hotel_id, authorization_code, cookie)
    proxies = Proxy.all
    # @hotel_reservation_code = params["hotel_reservation_code"]
    @hotel_reservation_code = hotel_reservation_code
    puts "hotel reservation code #{@hotel_reservation_code}"
    @hotel = Hotel.find(hotel_id)
    @hotel_id = hotel_id
    @scraping_session = ScrapingSession.create!(date: Time.now, hotel_id: @hotel_id)
    DateOfPrice.for_the_next_90_days
    #create hash of hashes with key ("date_of_price_id-room_category_id") and value will be 
    #a hash containing the price and the availability 
    @new_prices_objs = {}

    all_dates = DateOfPrice.where('date >= ?', Date.today ).first(180)

    all_rooms_categories = {}
    all_rooms_codes =  RoomCategory.where(hotel_id: hotel_id).map{|room_cat|
        all_rooms_categories[room_cat.room_code] = room_cat.id
        room_cat.room_code
    }
    
    dates_arr = []
    dates_plus_one_arr = []
    all_dates.map {|date|
        dates_arr << {"date": date.date.strftime("%d/%m/%Y"), "id": date.id }
        dates_plus_one_arr << date.date.next_day(1).strftime("%d/%m/%Y")
    }
    urls = []

    dates_arr.each_with_index{|date, index|
        urls << "https://secure.reservit.com/front2-0-12385/booking.do?step=2&nbroom=1&specialMode=default&hotelid=#{@hotel_reservation_code}&m=booking&langcode=FR&custid=2&currency=EUR&resetCookies=1&partid=0&fromStep=step2&fromDate=#{date[:date]}&toDate=#{dates_plus_one_arr[index]}&roomID=1&nbNight=1&nbRooms=1&numAdult(1)=2&numChild(1)=0&agesWithRoomID(1)=&id=2"
    }
    
    urls.each_with_index{|url, index|
    max_retries = 3
    times_retried = 0
    begin
        random_proxy = proxies.sample
        HTTParty::Basement.http_proxy(random_proxy.proxy_body, random_proxy.port, random_proxy.username, random_proxy.proxy_pass)
        @current_url = url
        response = HTTParty.get(url, 
            :headers => { 'Accept' =>  'application/json',
                    'Cookie' => cookie,
                    'Authorization' => authorization_code
                    } 
        )

        @room_categories_arr = []
        hotel_rooms_cats = RoomCategory.where(hotel_id: @hotel_id).map{|room_cat| {"room_code": room_cat.room_code, "id": room_cat.id}}
        unless hotel_rooms_cats.nil?
            @room_categories = hotel_rooms_cats.map {|room_cat| 
                @room_categories_arr << room_cat[:room_code]
                tempHash = {}
                tempHash['code'] = room_cat[:room_code]
                tempHash['id'] = room_cat[:id]
                tempHash
            }
        end
        if response["errors"]
            puts "hotel is fully booked on #{dates_arr[index][:id].to_s}"
            @room_categories.each{|room_cat|
                @new_prices_objs["#{dates_arr[index][:id]}-#{room_cat["id"]}"] = {"price": -1, "n_of_units_available": 0}
                new_price = Price.create!(price: -1, hotel_id: @hotel_id, room_category_id: room_cat["id"], n_of_units_available: 0,
                    date_of_price_id: dates_arr[index][:id], scraping_session_id: @scraping_session.id, available: false
                )
                # HotelsChannel.broadcast_to @hotel, new_price

            }  
        else 
    
            actual_rooms = response["datas"]["rooms"].map {|obj|
                @n_units = obj["rates"].map{|obj| obj["numberOfUnits"]}.max.to_i
                room_cat_name = obj["type"]["categoryName"]
                room_type_name = obj["type"]["typeName"]
                @price = obj["rates"].map{|obj| obj["price"]["amountAfterTax"]}.min.to_i
                puts "nb chambre: #{@n_units.to_s}, type de chambre: #{room_cat_name}, price: #{@price.to_s}"
                room_type = obj["rates"][0]["typeCode"].match(/^.*(?=(\-))/).to_s.to_i
                check_if_room_type_exits(room_type, room_cat_name, room_type_name)
                check_if_room_type_already_recorded(dates_arr[index][:id])
                room_type
            }
            #find rooms not available for this specific date and record them
            rooms_not_available = all_rooms_codes - actual_rooms 
            rooms_not_available.each{|room_code| 
                @new_prices_objs["#{dates_arr[index][:id]}-#{all_rooms_categories[room_code]}"] = {"price": -1, "n_of_units_available": 0}
                new_price = Price.create!(price: -1, hotel_id: @hotel_id, room_category_id: all_rooms_categories[room_code], n_of_units_available: 0,
                    date_of_price_id: dates_arr[index][:id], scraping_session_id: @scraping_session.id, available: false
                )
                # HotelsChannel.broadcast_to @hotel, new_price
            }
        end
        sleep 1
    # rescue HTTParty::Error
    #     fromDate = @current_url.match(/\A?fromdate=[^&]+&*/).slice!("fromDate").slice("&")
    #     ScrapingError.create(hotel_id: @hotel_id, scraping_session_id:
    #     @scraping_session.id, url_date: fromDate
    #     )
    #     next
    # end
    rescue 
    # rescue Net::ReadTimeout, Net::OpenTimeout, Errno::ECONNREFUSED, Errno::ECONNRESET, Net::HTTPFatalError  => error
        if times_retried < max_retries
        times_retried += 1
        puts "Failed to <do the thing>, retry #{times_retried}/#{max_retries}"
        retry
        else
        puts "ADD SPECIFIC DATE TO WORKER"
        break
        #   exit(1)
        end
    end
    }
    check_last_scraping_differences(@scraping_session.id, @hotel_id)
    @scraping_session.update(is_complete: true)
    send_scraping_session_to_client(@hotel_id)
  end
end
