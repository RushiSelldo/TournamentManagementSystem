require 'rails_helper'

RSpec.describe Participant::ParticipantService do
  let(:user) { create(:user) }
  let(:tournament) { create(:tournament) }
  let(:service) { described_class.new(user, tournament) }

  describe "#join_tournament" do
    context "when user has already joined the tournament" do
      before do
        team = create(:team, tournament: tournament)
        create(:team_member, team: team, user: user)
      end

      it "returns an error message" do
        result = service.join_tournament
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("You have already joined this tournament.")
      end
    end

    context "when a team exists with available slots" do
      let!(:team) { create(:team, tournament: tournament) }

      before do
        create_list(:team_member, 4, team: team) # 4 players in the team
      end

      it "adds user to the existing team" do
        result = service.join_tournament
        expect(result[:success]).to be_truthy
        expect(result[:team]).to eq(team)
        expect(team.team_members.count).to eq(5)
      end
    end

    context "when a new team needs to be created" do
      it "creates a new team and adds user" do
        result = service.join_tournament
        expect(result[:success]).to be_truthy
        expect(result[:team]).to be_persisted
        expect(result[:team].team_members.count).to eq(1)
        expect(result[:team].team_members.first.user).to eq(user)
      end
    end

    context "when team creation fails" do
      before do
        allow_any_instance_of(Team).to receive(:persisted?).and_return(false)
      end

      it "returns an error message" do
        result = service.join_tournament
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("Failed to create a new team.")
      end
    end

    context "when team member creation fails" do
      before do
        allow_any_instance_of(TeamMember).to receive(:persisted?).and_return(false)
        allow_any_instance_of(TeamMember).to receive_message_chain(:errors, :full_messages).and_return([ "Invalid member" ])
      end

      it "returns an error message" do
        result = service.join_tournament
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("Invalid member")
      end
    end
  end

  describe "#leave_tournament" do
    context "when user is not part of any team in the tournament" do
      it "returns an error message" do
        result = service.leave_tournament
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("You are not part of this tournament.")
      end
    end

    context "when user is part of a team but not a member" do
      let(:team) { create(:team, tournament: tournament) }

      it "returns an error message" do
        result = service.leave_tournament
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("You are not part of this tournament.")
      end
    end

    context "when user is a member of a team and removal succeeds" do
      let(:team) { create(:team, tournament: tournament) }

      before do
        create(:team_member, team: team, user: user)
      end

      it "removes the user from the team" do
        result = service.leave_tournament
        expect(result[:success]).to be_truthy
        expect(team.team_members.count).to eq(0)
      end

      it "destroys the team if no members left" do
        expect { service.leave_tournament }.to change { Team.count }.by(-1)
      end
    end

    context "when removal fails" do
      let(:team) { create(:team, tournament: tournament) }

      before do
        create(:team_member, team: team, user: user)
        allow_any_instance_of(TeamMember).to receive(:destroy).and_return(false)
      end

      it "returns an error message" do
        result = service.leave_tournament
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("Failed to leave the tournament.")
      end
    end
  end

  describe "#already_joined?" do
    context "when user is part of a team in the tournament" do
      before do
        team = create(:team, tournament: tournament)
        create(:team_member, team: team, user: user)
      end

      it "returns true" do
        expect(service.send(:already_joined?)).to be_truthy
      end
    end

    context "when user is not part of any team in the tournament" do
      it "returns false" do
        expect(service.send(:already_joined?)).to be_falsey
      end
    end
  end

  describe "#find_or_create_team" do
    context "when an existing team with an available slot is present" do
      let!(:team) { create(:team, tournament: tournament) }

      before do
        create_list(:team_member, 4, team: team) # 4 members
      end

      it "returns the existing team" do
        result = service.send(:find_or_create_team)
        expect(result).to eq(team)
      end
    end

    context "when no team with available slots exists" do
      it "creates a new team" do
        result = service.send(:find_or_create_team)
        expect(result).to be_persisted
        expect(result.name).to match(/Team [a-f0-9]{6}/)
      end
    end

    context "when creating a new team fails" do
      before do
        allow_any_instance_of(Team).to receive(:persisted?).and_return(false)
      end

      it "returns nil" do
        result = service.send(:find_or_create_team)
        expect(result).to be_nil
      end
    end
  end
end
