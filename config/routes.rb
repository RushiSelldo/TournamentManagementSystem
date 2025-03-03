Rails.application.routes.draw do
  get "dashboard/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  root to: "dashboard#index"


  get "/signup", to: "auth#signup"
  post "/signup", to: "auth#create_user"

  get "/login", to: "auth#login"
  post "/login", to: "auth#authenticate"

  # get "participant/dashboard", to: "participants#index"

  patch "/upgrade_to_host", to: "auth#upgrade_to_host"




  get "/logout", to: "auth#logout"
  delete "/logout", to: "auth#logout"


  get "/profile", to: "auth#profile"


   resources :users, only: [ :show, :update ]

   namespace :host do
    resources :tournaments do
      collection do
        get :count
        get :size
      end
    end
  end

  namespace :host do
    resources :tournaments do
      resources :matches, only: [ :new, :create, :edit, :update, :destroy ]
    end
  end



  namespace :participant do
    get "dashboard", to: "participants#index"
    get "available_tournaments", to: "participants#available", as: "available_tournaments"
    resources :participants, only: [ :index ] do
      member do
        post :join
        delete :leave
        get :matches
        get :teams
      end
    end
  end


  get "/profile", to: "auth#profile"
end
