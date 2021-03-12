Rails.application.routes.draw do
  get 'prices/new'
  get 'prices/create'
  get 'prices/update'
  get 'prices/destroy'
  get 'prices/index'
  get '/prices', to: 'prices#test'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
