Rails.application.routes.draw do
  devise_for :users

  root to: 'dashboard#index'

  namespace :batale do
    resources :analyses
    resources :errortogs do
      resources :definitions, except: %i[index], shallow: true
    end
    resources :strata
    resources :texts
  end

  namespace :btp do
    resources :analyses
    resources :blocs
    resources :colors
    resources :texts
  end

  resources :dashboard, only: :index
  resources :site, only: :index
  resources :users

  match '*path', to: 'dashboard#catch_404', via: :all
end
