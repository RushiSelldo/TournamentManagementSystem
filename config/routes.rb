Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  root "auth#login" # Default route to login

  get "/signup", to: "auth#signup"
  post "/signup", to: "auth#create_user"

  get "/login", to: "auth#login"
  post "/login", to: "auth#authenticate"

  delete "/logout", to: "auth#logout"

  get "/profile", to: "auth#profile"

   # User-related routes (requires authentication)
   resources :users, only: [ :show, :update ]

  # # Example protected route
  get "/profile", to: "auth#profile"  # Needs authentication
end
