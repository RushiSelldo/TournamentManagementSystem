require 'rails_helper'

RSpec.describe JsonWebToken do
  let(:payload) { { user_id: 1 } }
  let(:token) { described_class.encode(payload) }

  describe ".encode" do
    it "encodes a payload into a JWT token" do
      expect(token).to be_a(String)
    end

    it "includes the expiration time in the payload" do
      decoded = described_class.decode(token)
      expect(decoded[:exp]).not_to be_nil
    end
  end

  describe ".decode" do
    context "with a valid token" do
      it "decodes the token correctly" do
        decoded = described_class.decode(token)
        expect(decoded[:user_id]).to eq(payload[:user_id])
      end
    end

    context "with an expired token" do
      it "returns nil when the token is expired" do
        expired_token = described_class.encode(payload, 1.second.from_now)
        sleep 2
        decoded = described_class.decode(expired_token)
        expect(decoded).to be_nil
      end
    end

    context "with an invalid token" do
      it "returns nil for a malformed token" do
        expect(described_class.decode("invalid.token")).to be_nil
      end
    end
  end
end
