# # require 'rails_helper'
# # require 'factory_bot'

# RSpec.describe "Host::Tournaments", type: :request do
#   let!(:host) { create(:user, role: 'host') }
#   let!(:tournament1) { create(:tournament, name: "Tournament One", start_date: Date.today + 10) }
#   let!(:tournament2) { create(:tournament, name: "Tournament Two", start_date: Date.today + 20) }

#   # before do
#   #   # Stub current_user to simulate an authenticated host.
#   #   allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(host)
#   #   # Stub Pundit authorization to always succeed.
#   #   allow_any_instance_of(Host::TournamentsController).to receive(:authorize).and_return(true)
#   # end

#   describe "GET /host/tournaments" do
#     it "returns a successful response and displays tournaments" do
#       get host_tournaments_path
#       expect(response).to have_http_status(:ok)
#       expect(response.body).to include("Tournament One")
#       expect(response.body).to include("Tournament Two")
#     end
#   end
# end
