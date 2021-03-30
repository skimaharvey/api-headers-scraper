Rails.application.routes.draw do
  #prices routes
  get '/prices', to: 'prices#index'
  post '/prices', to: 'prices#create'
  post '/destroy_hotel_prices', to: 'prices#destroy_hotel_prices'
  #scraper routes
  post '/scraper', to: 'scraping_sessions#scraper_with_headers'
  post '/scraper_without_headers', to: 'scraping_sessions#scraper_without_headers'
  post '/all_competitors_scraper', to: 'scraping_sessions#launch_competitors_scraper'
  #hotels routes
  post '/new_hotel', to: 'hotels#create'
  post '/update_hotel', to: 'hotels#update'
  #users routes 
  post '/new_user', to: 'users#create'
  post '/login', to: 'login#create'
  post 'check_if_valid_session', to: 'login#check_if_valid_session'
  #action cable
  mount ActionCable.server => '/cable'
  #tripadvisor route 
  post '/create_trip_request', to: "tripadvisor_requests#create"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
