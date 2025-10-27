Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  post "/encode" => "shorten#encode", as: :encode
  post "/decode" => "shorten#decode", as: :decode
end
