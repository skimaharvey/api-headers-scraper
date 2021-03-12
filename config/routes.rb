Rails.application.routes.draw do

  get '/prices', to: 'prices#index'
  post '/prices', to: 'prices#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
