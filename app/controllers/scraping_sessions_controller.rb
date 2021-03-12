class ScrapingSessionsController < ApplicationController
    def scrape_reservit
        
        @hotel_reservation_code = params[:hotel_reservation_code]
        @hotel_id = Hotel.find_by(hotel_reservation_code: @hotel_reservation_code.to_i).id
        @scraping_session = ScrapingSession.create!(date: Time.now, hotel_id: @hotel_id)
        DateOfPrice.for_the_next_90_days
        all_dates = DateOfPrice.where('date >= ?', Date.today ).first(2)
        
        dates_arr = []
        dates_plus_one_arr = []
        all_dates.map {|date|
            dates_arr << {"date": date.date.strftime("%d/%m/%Y"), "id": date.id }
            dates_plus_one_arr << date.date.next_day(1).strftime("%d/%m/%Y")
        }
        urls = []
        dates_arr.each_with_index{|date, index|
            urls << "https://secure.reservit.com/front2-0-12385/booking.do?step=2&nbroom=1&specialMode=default&hotelid=#{@hotel_reservation_code}&m=booking&langcode=FR&custid=2&currency=EUR&resetCookies=1&partid=0&fromStep=step2&fromDate=#{date[:date]}&toDate=#{dates_plus_one_arr[index]}&roomID=1&nbNight=1&nbRooms=1&numAdult(1)=2&numChild(1)=0&agesWithRoomID(1)=&id=2"

            # urls << {"url": url, "date_id": date[:id], "room_id": room_cat[:room_id]}
            # puts date[:id]
        }

        authorization_code = params[:authorization_code]
        cookie =params[:cookie]

        def check_if_room_type_exits(room_code, room_name)
            if @room_categories_arr.include? room_code
               @room_id = @room_categories.select{|room_obj|
                   room_obj["code"] == room_code 
               }[0]['id']
               @room_id
            else 
                new_room_cat = RoomCategory.create!(name: room_name, hotel_id: @hotel_id, room_code: room_code, number_of_units: @n_units)
                @room_id = new_room_cat.id
            end
        end

        def check_if_room_type_already_recorded(date_id)
            #some rooms have more than one price (for example triple rooms) but we just want the cheapest option
            price_for_room_code = Price.where(scraping_session_id: @scraping_session.id, hotel_id: 
                @hotel_id, room_category_id: @room_id,  date_of_price_id:3
            )
            if price_for_room_code.present?
                unless price_for_room_code[0].price > @price 
                    price_for_room_code[0].update(price: @price)
                end
            else
                Price.create!(price: @price, hotel_id: @hotel_id, room_category_id: @room_id, n_of_units_available: @n_units,
                date_of_price_id: date_id, scraping_session_id: @scraping_session.id, available: true
                )
            end
        end
        
        urls.each_with_index{|url, index|
        begin
            @current_url = url
            response = HTTParty.get(url, 
            :headers => { 'Accept' =>  'application/json',
                        'Cookie' => cookie,
                        'Authorization' => authorization_code
                        } 
            )
            @room_categories_arr = []
            @room_categories = RoomCategory.where(hotel_id: @hotel_id).map {|room_cat| 
                @room_categories_arr << room_cat.room_code
                tempHash = {}
                tempHash['code'] = room_cat.room_code
                tempHash['id'] = room_cat.id
                tempHash
            }

            if response["errors"]
                puts "hotel is fully booked on #{dates_arr[index][:id].to_s}"
                @room_categories.each{|room_cat|
                    
                    Price.create!(price: -1, hotel_id: @hotel_id, room_category_id: room_cat["id"], n_of_units_available: 0,
                        date_of_price_id: dates_arr[index][:id], scraping_session_id: @scraping_session.id, available: false
                    )
                }  
            else 
                puts "date_id : #{dates_arr[index][:id]}"
                response["datas"]["rooms"].map {|obj|
                    @n_units = obj["rates"].map{|obj| obj["numberOfUnits"]}.max.to_i
                    room_cat_name = obj["type"]["categoryName"]
                    @price = obj["rates"].map{|obj| obj["price"]["amountAfterTax"]}.min.to_i
                    puts "nb chambre: #{@n_units.to_s}, type de chambre: #{room_cat_name}, price: #{@price.to_s}"
                    room_type = obj["rates"][0]["typeCode"].match(/^.*(?=(\-))/).to_s.to_i
                    check_if_room_type_exits(room_type, room_cat_name)
                    check_if_room_type_already_recorded(dates_arr[index][:id])
                }
            end
            sleep 1
        rescue HTTParty::Error
            fromDate = @current_url.match(/\A?fromdate=[^&]+&*/).slice!("fromDate").slice("&")
            ScrapingError.create(hotel_id: @hotel_id, scraping_session_id:
            @scraping_session.id, url_date: fromDate
            )
            next
        end
        }

        render json: {"hotel_id": @hotel_id}, status: 200
    end
end
