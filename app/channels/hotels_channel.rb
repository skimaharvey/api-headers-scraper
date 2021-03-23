class HotelsChannel < ApplicationCable::Channel
  def subscribed
    hotel = Hotel.find(params['hotel_id'])
    stream_for hotel
    # stream_from "hotel_50"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
