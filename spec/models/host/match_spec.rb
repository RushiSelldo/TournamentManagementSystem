require 'rails_helper'

RSpec.describe Match, type: :model do
  let(:tournament) { create(:tournament) }
  let(:team_1) { create(:team, tournament: tournament) }
  let(:team_2) { create(:team, tournament: tournament) }

  describe "associations" do
    it { should belong_to(:tournament) }
    it { should belong_to(:team_1).class_name('Team').with_foreign_key('team_1_id') }
    it { should belong_to(:team_2).class_name('Team').with_foreign_key('team_2_id') }
  end

  describe "validations" do
    subject {
      described_class.new(
        tournament: tournament,
        team_1: team_1,
        team_2: team_2,
        scheduled_at: Time.current,
        score_team_1: 1,
        score_team_2: 2
      )
    }

    it { should validate_presence_of(:scheduled_at) }
    it { should validate_presence_of(:team_1_id) }
    it { should validate_presence_of(:team_2_id) }

    it { should validate_numericality_of(:score_team_1).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:score_team_2).is_greater_than_or_equal_to(0) }

    context "when teams are different" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when teams are the same" do
      before do
        subject.team_2 = subject.team_1
      end

      it "is not valid and adds an error on team_2_id" do
        expect(subject).not_to be_valid
        expect(subject.errors[:team_2_id]).to include("must be different from Team 1")
      end
    end

    context "when score is negative" do
      it "is not valid if score_team_1 is negative" do
        subject.score_team_1 = -1
        expect(subject).not_to be_valid
        expect(subject.errors[:score_team_1]).to include("must be greater than or equal to 0")
      end

      it "is not valid if score_team_2 is negative" do
        subject.score_team_2 = -1
        expect(subject).not_to be_valid
        expect(subject.errors[:score_team_2]).to include("must be greater than or equal to 0")
      end
    end
  end

  describe "#teams_must_be_different" do
    it "adds an error when team_1 and team_2 are the same" do
      match = Match.new(
        tournament: tournament,
        team_1: team_1,
        team_2: team_1,
        scheduled_at: Time.current,
        score_team_1: 0,
        score_team_2: 0
      )
      expect(match).not_to be_valid
      expect(match.errors[:team_2_id]).to include("must be different from Team 1")
    end
  end
end
