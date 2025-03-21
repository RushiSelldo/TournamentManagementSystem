require 'rails_helper'

RSpec.describe TeamMember, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:team) }
  end

  describe 'validations' do
    it { should validate_presence_of(:role) }
    it { should validate_inclusion_of(:role).in_array(%w[player captain coach]) }
    it { should validate_presence_of(:joined_at) }

    context 'with a valid role' do
      it 'is valid with player role' do
        team_member = TeamMember.new(user: create(:user), team: create(:team), role: 'player', joined_at: Date.today)
        expect(team_member).to be_valid
      end

      it 'is valid with captain role' do
        team_member = TeamMember.new(user: create(:user), team: create(:team), role: 'captain', joined_at: Date.today)
        expect(team_member).to be_valid
      end

      it 'is valid with coach role' do
        team_member = TeamMember.new(user: create(:user), team: create(:team), role: 'coach', joined_at: Date.today)
        expect(team_member).to be_valid
      end
    end

    context 'with an invalid role' do
      it 'is not valid with an invalid role' do
        team_member = TeamMember.new(user: create(:user), team: create(:team), role: 'manager', joined_at: Date.today)
        expect(team_member).not_to be_valid
        expect(team_member.errors[:role]).to include('is not included in the list')
      end
    end

    context 'without a joined_at date' do
      it 'is not valid without joined_at' do
        team_member = TeamMember.new(user: create(:user), team: create(:team), role: 'player', joined_at: nil)
        expect(team_member).not_to be_valid
        expect(team_member.errors[:joined_at]).to include("can't be blank")
      end
    end
  end
end
