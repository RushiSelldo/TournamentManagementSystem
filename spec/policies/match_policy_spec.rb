require 'rails_helper'

RSpec.describe MatchPolicy do
  subject { described_class.new(user, match) }

  let(:user) { create(:user) }
  let(:tournament) { create(:tournament, host: user) }
  let(:match) { create(:match, tournament: tournament) }

  context "when user is the host of the tournament" do
    before do
      allow(user).to receive(:hosted_tournaments).and_return([ tournament ])
    end

    it "allows creating a match" do
      expect(subject.create?).to be_truthy
    end

    it "allows updating a match" do
      expect(subject.update?).to be_truthy
    end

    it "allows destroying a match" do
      expect(subject.destroy?).to be_truthy
    end
  end

  context "when user is NOT the host of the tournament" do
    let(:other_tournament) { create(:tournament) }
    let(:match) { create(:match, tournament: other_tournament) }

    before do
      # Ensure user is NOT the host of the tournament
      allow(user).to receive(:hosted_tournaments).and_return([])
    end

    it "denies creating a match" do
      expect(subject.create?).to be_falsey
    end

    it "denies updating a match" do
      expect(subject.update?).to be_falsey
    end

    it "denies destroying a match" do
      expect(subject.destroy?).to be_falsey
    end
  end
end
