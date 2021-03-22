class LoginController < ApplicationController

    def check_if_valid_session
      user_id = check_current_user(params["token"])
      if user_id.nil?
        render json: { errors: "Sorry, incorrect username or password"  }, status: :unprocessable_entity
      else
        hotels = Hotel.all
        dates = DateOfPrice.where('date >= ?', Date.today ).first(80)
        user = User.find(user_id)
        room_categories = {}
        user_hotel = user.hotel
        last_user_hotel_scraping_session = user_hotel.scraping_sessions.last
        user_hotel_prices = user_hotel.prices.where(scraping_session_id: last_user_hotel_scraping_session)
        user.hotel.room_categories.each{|room_cat|
          room_categories[room_cat.id] = room_cat
        }
        comptetitors_prices = user.hotels.map{|hotel|
          last_hotel_scraping_session = hotel.scraping_sessions.last
          room_cats = hotel.room_categories
          room_cats.each{|room_cat|
            room_categories[room_cat.id] = room_cat
          }
          hotel.prices.where(scraping_session_id: last_hotel_scraping_session)
        }
        render json: { token: token(user.id), 
          user_hotel_prices: user_hotel_prices, 
          comptetitors_prices: comptetitors_prices,
          hotels: hotels,
          dates: dates,
          user_id: user.id,
          room_categories: room_categories
        }, status: :created 
      end

    end

    def create
        user = User.find_by(email: params[:email].downcase)
        if user && user.authenticate(params[:password])
          hotels = Hotel.all
          dates = DateOfPrice.where('date >= ?', Date.today ).first(80)
          room_categories = {}
          user_hotel = user.hotel
          last_user_hotel_scraping_session = user_hotel.scraping_sessions.last
          user_hotel_prices = user_hotel.prices.where(scraping_session_id: last_user_hotel_scraping_session)
          user.hotel.room_categories.each{|room_cat|
            room_categories[room_cat.id] = room_cat
          }
          comptetitors_prices = user.hotels.map{|hotel|
            last_hotel_scraping_session = hotel.scraping_sessions.last
            room_cats = hotel.room_categories
            room_cats.each{|room_cat|
              room_categories[room_cat.id] = room_cat
            }
            hotel.prices.where(scraping_session_id: last_hotel_scraping_session)
          }
          render json: { token: token(user.id), 
            user_hotel_prices: user_hotel_prices, 
            comptetitors_prices: comptetitors_prices,
            hotels: hotels,
            dates: dates,
            room_categories: room_categories,
            user_id: user.id
          }, status: :created 
        else 
          render json: { errors: "Sorry, incorrect username or password"  }, status: :unprocessable_entity
        end 
      end
    
      private 
      def user_params
        params.require(:user).permit(:username, :password)
      end
end
