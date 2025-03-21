require 'rails_helper'

RSpec.describe TournamentPolicy do
  subject { described_class.new(user, tournament) }

  let(:host) { create(:user, role: 'host') }
  let(:tournament) { create(:tournament, host: host) }

  describe ".Scope" do
    subject { TournamentPolicy::Scope.new(user, Tournament).resolve }

    context "when user is a guest (not logged in)" do
      let(:user) { nil }

      it "returns all tournaments" do
        create_list(:tournament, 3)
        expect(subject.count).to eq(Tournament.count)
      end
    end

    context "when user is a participant" do
      let(:user) { create(:user, role: 'participant') }

      it "returns all tournaments" do
        create_list(:tournament, 3)
        expect(subject.count).to eq(Tournament.count)
      end
    end

    context "when user is a host" do
      let(:user) { host }

      it "returns all tournaments" do
        create_list(:tournament, 3)
        expect(subject.count).to eq(Tournament.count)
      end
    end
  end

  # ✅ Test Policy Methods
  describe "Permissions" do
    context "when user is a guest (not logged in)" do
      let(:user) { nil }

      it { expect(subject.index?).to be_truthy }
      it { expect(subject.show?).to be_truthy }
      it { expect(subject.create?).to be_falsey }
      it { expect(subject.update?).to be_falsey }
      it { expect(subject.destroy?).to be_falsey }
      it { expect(subject.count?).to be_truthy }
    end

    context "when user is a participant" do
      let(:user) { create(:user, role: 'participant') }

      it { expect(subject.index?).to be_truthy }
      it { expect(subject.show?).to be_truthy }
      it { expect(subject.create?).to be_falsey }
      it { expect(subject.update?).to be_falsey }
      it { expect(subject.destroy?).to be_falsey }
      it { expect(subject.count?).to be_truthy }
    end

    context "when user is a host" do
      let(:user) { host }

      it { expect(subject.index?).to be_truthy }
      it { expect(subject.show?).to be_truthy }
      it { expect(subject.create?).to be_truthy }
      it { expect(subject.update?).to be_truthy }
      it { expect(subject.destroy?).to be_truthy }
      it { expect(subject.count?).to be_truthy }
    end

    context "when user is a host but not the owner of the tournament" do
      let(:user) { create(:user, role: 'host') }

      it { expect(subject.index?).to be_truthy }
      it { expect(subject.show?).to be_truthy }
      it { expect(subject.create?).to be_truthy }
      it { expect(subject.update?).to be_falsey }
      it { expect(subject.destroy?).to be_falsey }
      it { expect(subject.count?).to be_truthy }
    end

    context "when user is nil" do
      let(:user) { nil }
      let(:tournament) { nil }

      it { expect(subject.index?).to be_truthy }
      it { expect(subject.show?).to be_truthy }
      it { expect(subject.create?).to be_falsey }
      it { expect(subject.update?).to be_falsey }
      it { expect(subject.destroy?).to be_falsey }
      it { expect(subject.count?).to be_truthy }
    end
  end
end
