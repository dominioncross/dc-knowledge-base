# frozen_string_literal: true

KnowledgeBase::Engine.routes.draw do
  root to: 'home#index'
  get '/init.json', to: 'home#init'
  post '/config/set_password', to: 'config#set_password'
  post '/config/signin', to: 'config#signin'
  patch '/:id/subscribe', to: 'channels#subscribe'

  resource :config, controller: :config

  resources :channels
  resources :flags do
    collection do
      post :toggle
    end
  end
  resources :subscribers
  resources :messages do
    member do
      patch :pin
      patch :update_status
    end
  end

  get ':channel', to: 'home#index', as: :channel_path
end
