Rails.application.routes.draw do
  #prices routes
  get '/prices', to: 'prices#index'
  post '/prices', to: 'prices#create'
  post '/destroy_hotel_prices', to: 'prices#destroy_hotel_prices'
  #scraper routes
  post '/scraper', to: 'scraping_sessions#scraper'
  post '/scraper_without_headers', to: 'scraping_sessions#scraper_without_headers'
  #hotels routes
  post '/new_hotel', to: 'hotels#create'
  post '/update_hotel', to: 'hotels#update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
