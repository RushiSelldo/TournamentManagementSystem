require 'rails_helper'

RSpec.describe ParticipantPolicy do
  subject { described_class.new(user, nil) } # No specific record involved for this policy

  context "when user is a participant" do
    let(:user) { create(:user, role: "participant") }

    it "allows access to index" do
      expect(subject.index?).to be_truthy
    end

    it "allows access to available" do
      expect(subject.available?).to be_truthy
    end

    it "allows joining a tournament" do
      expect(subject.join?).to be_truthy
    end

    it "allows leaving a tournament" do
      expect(subject.leave?).to be_truthy
    end

    it "allows viewing matches" do
      expect(subject.matches?).to be_truthy
    end

    it "allows viewing teams" do
      expect(subject.teams?).to be_truthy
    end
  end

  context "when user is NOT a participant" do
    let(:user) { create(:user, role: "host") } # Or any other role

    it "denies access to index" do
      expect(subject.index?).to be_falsey
    end

    it "denies access to available" do
      expect(subject.available?).to be_falsey
    end

    it "denies joining a tournament" do
      expect(subject.join?).to be_falsey
    end

    it "denies leaving a tournament" do
      expect(subject.leave?).to be_falsey
    end

    it "denies viewing matches" do
      expect(subject.matches?).to be_falsey
    end

    it "denies viewing teams" do
      expect(subject.teams?).to be_falsey
    end
  end
end
