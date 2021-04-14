class PricesController < ApplicationController
  before_action :require_login
  def new
  end

  def create
    @price = Price.new(price: params["price"], available: params["available"], n_of_units_available: params["n_of_units_available"])
    if @price.save 
      render json: @price, status: 200
    else 
      render json: {error: 'not working'}, status: 400
    end
  end

  def update
  end

  def destroy_hotel_prices
    Price.where(hotel_id: params["hotel_id"]).destroy_all 
    render json: {message: "Sucess"}, status: 200
  end

  def index
    @prices = Price.all
    render  :json => @prices
  end

  def fetch_all_price
    # start_date = params['startDate']
    # end_date = params['endDate']
    user_id = check_current_user(params["token"])

    if user_id.nil?
      render json: { errors: "Sorry, incorrect username or password"  }, status: :unprocessable_entity
    else

      user = User.find(user_id)
      hotels = Hotel.all
      dates = DateOfPrice.where(  "date >= :start_date AND date <= :end_date",
        { start_date: params['startDate'],
          end_date: params['endDate']
        }
      )
      room_categories = {}
      user_hotel = user.hotel
      all_hotels_ids = [] 
      all_hotels_ids.push(user_hotel.id)

      last_user_hotel_scraping_session = user_hotel.scraping_sessions.where(is_ota_type: nil).last
      user_hotel_prices = user_hotel.prices.where(scraping_session_id: last_user_hotel_scraping_session)
      user.hotel.room_categories.each{|room_cat|
        room_categories[room_cat.id] = room_cat
      }
      comptetitors_prices = user.hotels.map{|hotel|
        all_hotels_ids.push(hotel.id)
        last_hotel_scraping_session = hotel.scraping_sessions.where(is_ota_type: nil).last
        room_cats = hotel.room_categories
        room_cats.each{|room_cat|
          room_categories[room_cat.id] = room_cat
        }
        #SET UP SERIALIZER
        hotel.prices.where(scraping_session_id: last_hotel_scraping_session)
      }
      #all_otas_prices for last scraping session 
      last_scraping_sessions_ids = []
      scraping_sessions_ids = all_hotels_ids.map{|hotel_id|
        if ScrapingSession.where(hotel_id: hotel_id, is_ota_type: true).length > 0
          ScrapingSession.where(hotel_id: hotel_id, is_ota_type: true).last.id
        end
      }
      
      all_otas_prices = OtaPrice.where(scraping_session_id: scraping_sessions_ids)
      
      render json: { token: token(user.id), 
        user_hotel_prices: user_hotel_prices, 
        comptetitors_prices: comptetitors_prices,
        dates: dates,
        ota_prices: all_otas_prices
      }, status: :created 
    end
  end

  private 

  # def price_params
  #   params.require(:price).permit(:available, :n_of_units_available)
  # end
end
