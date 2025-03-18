require 'rails_helper'

RSpec.describe Host::TournamentService, type: :service do
  let(:user) { create(:user) }
  let(:tournament) { create(:tournament, user: user) }
  let(:valid_params) { { name: "Championship", location: "Stadium", start_date: Date.today } }
  let(:invalid_params) { { name: "", location: "", start_date: nil } }

  describe "#count" do
    it "returns the total number of tournaments" do
      create_list(:tournament, 3)
      service = described_class.new(user)

      expect(service.count).to eq(3)
    end
  end

  describe "#list_tournaments" do
    it "returns tournaments in descending order of creation" do
      tournament1 = create(:tournament, created_at: 2.days.ago)
      tournament2 = create(:tournament, created_at: 1.day.ago)
      service = described_class.new(user)

      expect(service.list_tournaments).to eq([ tournament2, tournament1 ])
    end
  end

  describe "#find_tournament" do
    it "returns the tournament if found" do
      service = described_class.new(user)

      expect(service.find_tournament(tournament.id)).to eq(tournament)
    end

    it "raises ActiveRecord::RecordNotFound if tournament is not found" do
      service = described_class.new(user)

      expect {
        service.find_tournament(-1)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#create_tournament" do
    context "with valid params" do
      it "creates a new tournament and returns success" do
        service = described_class.new(user, valid_params)
        result = service.create_tournament

        expect(result[:success]).to be true
        expect(result[:tournament]).to be_persisted
        expect(result[:tournament].name).to eq(valid_params[:name])
      end
    end

    context "with invalid params" do
      it "returns failure and errors" do
        service = described_class.new(user, invalid_params)
        result = service.create_tournament

        expect(result[:success]).to be false
        expect(result[:errors]).to include("Name can't be blank", "Location can't be blank", "Start date can't be blank")
      end
    end
  end

  describe "#update_tournament" do
    context "with valid params" do
      it "updates the tournament and returns success" do
        service = described_class.new(user, { name: "Updated Championship" })
        result = service.update_tournament(tournament)

        expect(result[:success]).to be true
        expect(result[:tournament].name).to eq("Updated Championship")
      end
    end

    context "with invalid params" do
      it "returns failure and errors" do
        service = described_class.new(user, { name: "" })
        result = service.update_tournament(tournament)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("Name can't be blank")
      end
    end
  end

  describe "#delete_tournament" do
    context "when deletion is successful" do
      it "deletes the tournament and returns success" do
        service = described_class.new(user)

        result = service.delete_tournament(tournament)

        expect(result[:success]).to be true
        expect(Tournament.exists?(tournament.id)).to be false
      end
    end

    context "when deletion fails" do
      it "returns failure and errors" do
        # Simulate deletion failure using a mock
        allow_any_instance_of(Tournament).to receive(:destroy).and_return(false)
        allow(tournament).to receive_message_chain(:errors, :full_messages).and_return([ "Deletion failed" ])

        service = described_class.new(user)
        result = service.delete_tournament(tournament)

        expect(result[:success]).to be false
        expect(result[:errors]).to include("Deletion failed")
      end
    end
  end
end
