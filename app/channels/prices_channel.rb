class PricesChannel < ApplicationCable::Channel
  def subscribed
    # hotel = Hotel.find(params['hotel_id'])
    # stream_for hotel
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
