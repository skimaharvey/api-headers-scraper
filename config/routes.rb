Rails.application.routes.draw do
  #prices routes
  get '/prices', to: 'prices#index'
  post '/prices', to: 'prices#create'
  #scraper routes
  post '/scrape_reservit', to: 'scraping_sessions#scrape_reservit'
  #hotels routes
  post '/new_hotel', to: 'hotels#create'
  post '/update_hotel', to: 'hotels#update'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
