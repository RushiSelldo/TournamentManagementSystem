require 'rails_helper'

RSpec.describe Tournament, type: :model do
  describe 'associations' do
    it { should belong_to(:host).class_name('User') }
    it { should have_many(:teams).dependent(:destroy) }
    it { should have_many(:matches).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:start_date) }

    context 'when start_date is in the past' do
      it 'is not valid' do
        tournament = Tournament.new(name: 'Test Tournament', start_date: Date.yesterday)
        expect(tournament).not_to be_valid
        expect(tournament.errors[:start_date]).to include("can't be in the past")
      end
    end

    context 'when start_date is today or in the future' do
      let(:host) { create(:user, role: 'host') }

      it 'is valid with today’s date' do
        tournament = Tournament.new(name: 'Test Tournament', start_date: Date.today, host: host)
        expect(tournament).to be_valid
      end

      it 'is valid with a future date' do
        tournament = Tournament.new(name: 'Test Tournament', start_date: Date.today + 1, host: host)
        expect(tournament).to be_valid
      end
    end
  end
end
