class ReservitCreateWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def create_if_room_type_exits(room_code, room_name, room_type_name, n_units, hotel_id)
    if @room_categories_arr.include? room_code
        specific_room_cat = RoomCategory.where(room_code: room_code, hotel_id: hotel_id)[0]
        if specific_room_cat.number_of_units < n_units 
            specific_room_cat.update(number_of_units: n_units)
        end
    else 
        new_room_cat = RoomCategory.create!(name: room_name, hotel_id: @hotel_id, 
        room_code: room_code, number_of_units: @n_units, room_type_name: room_type_name)
        @room_id = new_room_cat.id
        @room_categories_arr.push(room_code)
    end
  end

  def perform(hotel_reservation_code, authorization_code, cookie, hotel_id)
    proxies = Proxy.all
    @hotel_reservation_code = hotel_reservation_code
    @hotel_id = hotel_id
    DateOfPrice.for_the_next_90_days
    all_dates = DateOfPrice.where('date >= ?', Date.today ).first(60)
    @room_categories_arr = []
    hotel_rooms_cats = RoomCategory.where(hotel_id: @hotel_id).map{|room_cat| room_cat.room_code}


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
    # print "cookie: #{cookie}" 
    # print authorization_code
    urls.each_with_index{|url, index|
    # begin
        random_proxy = proxies.sample
        HTTParty::Basement.http_proxy(random_proxy.proxy_body, random_proxy.port, random_proxy.username, random_proxy.proxy_pass)
        @current_url = url
        response = HTTParty.get(url, 
        :headers => { 'Accept' =>  'application/json',
                    'Cookie' => cookie,
                    'Authorization' => authorization_code
                    } 
        )
        # print response
        if response["errors"]
            puts "hotel is fully booked on #{dates_arr[index][:id].to_s}"
        else 
           
            actual_rooms = response["datas"]["rooms"].map {|obj|
                @n_units = obj["rates"].map{|obj| obj["numberOfUnits"]}.max.to_i
                room_cat_name = obj["type"]["categoryName"]
                room_type_name = obj["type"]["typeName"]
                #get room id 
                room_type = obj["rates"][0]["typeCode"].match(/^.*(?=(\-))/).to_s.to_i
                create_if_room_type_exits(room_type, room_cat_name, room_type_name, @n_units, @hotel_id)
                room_type
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
    }
    ReservitWorker.perform_async(hotel_reservation_code, @hotel_id, authorization_code, cookie)
  end
end
