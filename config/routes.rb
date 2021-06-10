Rails.application.routes.draw do
  get "/api/v1/courses", to: 'api_v1#index'
  options "/api/v1/courses", to: 'api_v1#options'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end