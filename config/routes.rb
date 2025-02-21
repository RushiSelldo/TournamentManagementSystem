Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  root to: redirect("/dashboard.html")


  get "/signup", to: "auth#signup"
  post "/signup", to: "auth#create_user"

  get "/login", to: "auth#login"
  post "/login", to: "auth#authenticate"



get "/logout", to: "auth#logout"
  delete "/logout", to: "auth#logout"

  get "/profile", to: "auth#profile"


   resources :users, only: [ :show, :update ]

   namespace :host do
    resources :tournaments
  end
  get "/profile", to: "auth#profile"
end
