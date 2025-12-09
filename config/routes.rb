Rails.application.routes.draw do
  get 'notes/create'
  devise_for :users
  root to: "pages#home"

  # Multiplayer section
  get 'multiplayer', to: 'multiplayer#index', as: :multiplayer
  get 'league', to: 'multiplayer#league', as: :league

  # Social / Friends system
  resources :friendships, only: [:index, :create, :destroy] do
    member do
      patch :accept
      patch :reject
    end
  end

  # Users listing and profiles
  resources :users, only: [:index, :show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :uploads, only: [:index, :create]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :lectures, only: %i[index show edit update new create destroy] do
    resources :notes, only: %i[new create]
    resources :messages, only: %i[new create]
    resources :flashcards, only: %i[new create]
  end

  # New quiz system - standalone, organized by category
  resources :quizzes, only: [:index, :show, :new, :create] do
    resources :attempts, only: [:create, :show] do
      member do
        patch :submit
      end
    end
  end

  resources :notes, only: :destroy

  resources :challenges, only: [:index, :new, :destroy] do
    resources :challenge_users, only: [:create, :show]
  end


  resources :flashcards, only: [:show, :destroy] do
    member do
      patch :update_progress
    end
    resources :flashcard_completions
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
