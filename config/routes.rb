Rails.application.routes.draw do
  root to: "dashboard#index"
  get "dashboard/index"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.


  get "/signup", to: "auth#signup"
  post "/signup", to: "auth#create_user"

  get "/login", to: "auth#login"
  post "/login", to: "auth#authenticate"

  post "/forgot_password", to: "auth#forgot_password"
post "/reset_password", to: "auth#reset_password"


  # get "participant/dashboard", to: "participants#index"

  patch "/upgrade_to_host", to: "auth#upgrade_to_host"




  get "/logout", to: "auth#logout"
  delete "/logout", to: "auth#logout"


  get "/profile", to: "auth#profile"


   resources :users, only: [ :show, :update ]

   namespace :host do
    resources :tournaments do
      collection do
        get "my_tournaments"
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
