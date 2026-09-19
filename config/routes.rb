Rails.application.routes.draw do
  direct :starterapp_image do |model, options|
    if ImgproxyRails::Helpers.applicable_variation?(model)
      Images::VariantUrl.call(model)
    else
      route_for(:rails_storage_proxy, model, options)
    end
  end

  if Rails.env.development?
    # Сохраняет hostname браузера или Android; преобразование и выдача байтов выполняются в Go.
    get "images/*path", to: redirect(status: 302) { |params, request|
      "http://#{request.host}:8082/images/#{params.fetch(:path)}"
    }, format: false
  end

  get "up" => "rails/health#show", as: :rails_health_check
  namespace :admin do
    root "dashboard#show"
    resource :observability, only: :show, controller: "observability"
  end
  namespace :operations, path: "ops" do
    resources :agents, only: :index
    resource :health, only: :show, controller: "health"
    resource :metrics, only: :show, controller: "metrics"
  end
  mount MissionControl::Jobs::Engine, at: "/ops/jobs"
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]
  resource :account, only: :show
  root "home#index"

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?
end
