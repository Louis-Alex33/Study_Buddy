Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :uploads, only: [:index, :create]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :categories, only: %i[new create] do
    resources :lectures, only: %i[new create]
  end

  resources :lectures, only: %i[show edit update] do
    resources :notes, only: %i[new create]
    resources :messages, only: %i[new create]
    resources :flashcards, only: %i[new create]
  end

  resources :flashcards, only: [:show] do
    resources :flashcard_completions
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
