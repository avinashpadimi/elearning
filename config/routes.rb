Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #
  namespace :api do 
    namespace :v1 do 
      jsonapi_resources :courses
      jsonapi_resources :coaches
    end
  end
end
