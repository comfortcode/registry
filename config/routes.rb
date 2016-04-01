Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'sessions' }
  resources :items, except: :index
  root to: 'public#landing'

  # Routes for created views  
  get 'items/:id/gotit', to: 'items#got_it', as: :got_it
  get 'fulfillments', to: 'fulfillments#index', as: :fulfillments

  # Routes for created methods  
  post 'fulfillments/create', to: 'fulfillments#create'
  post 'fulfillments/usercreate', to: 'fulfillments#user_create', as: :fulfillments_user_create
  patch 'fulfillments/:id/fulfill', to: 'fulfillments#mark_seen', as: :fulfill
  patch 'fulfillments/:id/spam', to: 'fulfillments#mark_spam', as: :spam
  get 'search', to: 'public#search_results', as: :search
  get 'scrape', to: 'public#scrape', as: :scrape
  get 'new_user_registration_collect_email', to: 'public#new_user_registration_collect_email', as: :new_user_registration_collect_email

  # Keep this route last (to prevent routing errors)
  get '/:link_id', to: 'items#index', as: :user_registry
  
end