class PricesController < ApplicationController
  def new
  end

  def create
  end

  def update
  end

  def destroy
  end
  def test 
    @prices = Price.all
    render :json => {"message": "hello"}
  end
  def index
    @prices 
    render render :json => @prices
  end
end
