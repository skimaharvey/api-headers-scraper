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

  private 

  # def price_params
  #   params.require(:price).permit(:available, :n_of_units_available)
  # end
end
