class ScraperAvailpro < ApplicationRecord

    def self.launch_scraper(hotel_id, url, verification_token,cookie)
        # hotel_id = 2
        @room_cats_ids = {}
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


        dates_arr.each_with_index{|date, index|
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
                    Price.create!(price: -1, hotel_id: hotel_id, room_category_id: value,
                    date_of_price_id: date[:id], n_of_units_available: 0, available: false, 
                    scraping_session_id: scraping_session.id)
                }
            else
                response["data"]["rooms"].map { |obj|
                    room_id = @room_cats_ids[obj['roomId']].to_i
                    room_name = @room_cats_ids[obj['name']]
                    quantity = obj["rates"][0]["availability"].to_i
                    ScraperAvailpro.check_if_room_type_exits(room_id, room_name, hotel_id, quantity)
                    price = obj["rates"].map{|rateObj|
                            rateObj["price"].to_i
                            }.min
                    puts "price: #{price}, room cat: #{room_id}"
                    Price.create!(price: price, hotel_id: hotel_id, room_category_id: room_id,
                    date_of_price_id: date[:id], n_of_units_available: quantity, available: true,
                    scraping_session_id: scraping_session.id)
                }
            end
            sleep 1
        }
    end 

    def self.check_if_room_type_exits(room_code, room_name, hotel_id, quantity)

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

    def self.create_room_categories(hotel_id, url, verification_token,cookie)
        @room_cats_ids = {}
        @room_categories_arr = RoomCategory.where(hotel_id: hotel_id).each{|room_cat|
            @room_cats_ids[room_cat.room_code] = room_cat.id
            room_cat.room_code
        }

        all_dates = DateOfPrice.where('date >= ?', Date.today ).first(60)
        dates_arr = []
        dates_plus_one_arr = []
        all_dates.each {|date|
            dates_arr << {"date": date.date.strftime("%Y-%m-%d"), "id": date.id }
            dates_plus_one_arr << date.date.next_day(1).strftime("%Y-%m-%d")
        }


        dates_arr.each_with_index{|date, index|
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
            else
                response["data"]["rooms"].map { |obj|
                    room_id = obj['roomId'].to_i
                    room_name = obj['name']
                    quantity = obj["rates"][0]["availability"].to_i
                    ScraperAvailpro.check_if_room_type_exits(room_id, room_name, hotel_id, quantity)
                }
            end
            sleep 1
        }
    end
end