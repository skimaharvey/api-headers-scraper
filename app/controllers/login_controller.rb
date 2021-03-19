class LoginController < ApplicationController

    def fetch_hotels_prices(user_id)

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
            room_categories: room_categories
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
