require 'sidekiq/web'

Rails.application.routes.draw do
  #prices routes
  get '/prices', to: 'prices#index'
  post '/prices', to: 'prices#create'
  post '/destroy_hotel_prices', to: 'prices#destroy_hotel_prices'
  post '/fetch_all_price', to: 'prices#fetch_all_price'
  #scraper routes
  post '/scraper', to: 'scraping_sessions#scraper_with_headers'
  post '/scraper_without_headers', to: 'scraping_sessions#scraper_without_headers'
  post '/all_competitors_scraper', to: 'scraping_sessions#launch_competitors_scraper'
  post '/scrape_specific_hotel', to: 'scraping_sessions#scrape_specific_hotel'
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
  post '/fetch_user_otas', to: "tripadvisor_requests#fetch_all_user_otas" 
  post "/fetch_specific_hotel_ota", to: 'tripadvisor_requests#fetch_specific_hotel_ota'
  #ota scraper routes
  post "/scrape_hotel_ota", to: 'ota_scrapers#scraper_specific_hotel'
  #rooms routes
  post '/room_categories_list', to: 'room_categories#room_categories_list'
  post '/fetch_rooms_equivalences', to: 'room_categories#fetch_rooms_equivalences'
  #prices changes and new reservations
  post '/last_changes', to: 'changes#last_changes'
  #proxies 
  post "/create_proxy", to: 'proxies#create'
  post "/delete_proxies", to: 'proxies#delete'
  get "/proxies", to: 'proxies#index'

  mount Sidekiq::Web => '/sidekiq'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
