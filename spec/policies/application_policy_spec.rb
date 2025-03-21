require 'rails_helper'

RSpec.describe ApplicationPolicy do
  subject { described_class.new(user, record) }

  let(:user) { create(:user) }
  let(:record) { double("Record") }

  describe "#index?" do
    it "returns false by default" do
      expect(subject.index?).to be_falsey
    end
  end

  describe "#show?" do
    it "returns false by default" do
      expect(subject.show?).to be_falsey
    end
  end


  describe "#create?" do
    it "returns false by default" do
      expect(subject.create?).to be_falsey
    end
  end

  describe "#new?" do
    it "calls #create?" do
      expect(subject).to receive(:create?).and_return(true)
      expect(subject.new?).to be_truthy
    end
  end

  # -----------------------------------------------
  # ✅ TESTS FOR #update?
  # -----------------------------------------------
  describe "#update?" do
    it "returns false by default" do
      expect(subject.update?).to be_falsey
    end
  end

  # -----------------------------------------------
  # ✅ TESTS FOR #edit?
  # -----------------------------------------------
  describe "#edit?" do
    it "calls #update?" do
      expect(subject).to receive(:update?).and_return(true)
      expect(subject.edit?).to be_truthy
    end
  end

  # -----------------------------------------------
  # ✅ TESTS FOR #destroy?
  # -----------------------------------------------
  describe "#destroy?" do
    it "returns false by default" do
      expect(subject.destroy?).to be_falsey
    end
  end


  describe "Scope" do
    subject { described_class::Scope.new(user, double("Scope")) }

    it "raises NoMethodError if #resolve is not defined" do
      expect { subject.resolve }.to raise_error(NoMethodError, /You must define #resolve in ApplicationPolicy::Scope/)
    end
  end
end
