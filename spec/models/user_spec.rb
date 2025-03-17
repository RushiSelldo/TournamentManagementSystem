require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:hosted_tournaments).with_foreign_key(:host_id).class_name('Tournament') }
    it { is_expected.to have_many(:team_members) }
    it { is_expected.to have_many(:teams).through(:team_members) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(50) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('test@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid-email').for(:email) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_inclusion_of(:role).in_array(%w[host participant admin]) }
  end

  describe 'callbacks' do
    context 'before_save' do
      it 'downcases email before saving' do
        user = create(:user, email: 'Test@EXAMPLE.COM', password: 'password123', password_confirmation: 'password123')
        expect(user.email).to eq('test@example.com')
      end
    end

    context 'after_initialize' do
      it 'sets default role to participant if not set' do
        user = User.new(name: 'John Doe', email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
        expect(user.role).to eq('participant')
      end

      it 'does not override an existing role' do
        user = User.new(name: 'Jane Doe', email: 'test@example.com', password: 'password123', password_confirmation: 'password123', role: 'admin')
        expect(user.role).to eq('admin')
      end
    end
  end

  describe 'secure password' do
    it 'authenticates with a valid password' do
      user = create(:user, password: 'password123', password_confirmation: 'password123')
      expect(user.authenticate('password123')).to be_truthy
    end

    it 'does not authenticate with an invalid password' do
      user = create(:user, password: 'password123', password_confirmation: 'password123')
      expect(user.authenticate('wrongpassword')).to be_falsey
    end
  end
end
