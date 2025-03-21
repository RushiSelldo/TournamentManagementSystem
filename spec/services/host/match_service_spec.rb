require 'rails_helper'

RSpec.describe Host::MatchService do
  let(:tournament) { create(:tournament) }
  let(:match) { create(:match, tournament: tournament) }
  let(:params) { { scheduled_at: 1.day.from_now, location: 'Stadium A' } }

  describe '#initialize' do
    it 'initializes with tournament and params' do
      service = Host::MatchService.new(tournament, params)
      expect(service.instance_variable_get(:@tournament)).to eq(tournament)
      expect(service.instance_variable_get(:@params)).to eq(params)
    end

    it 'initializes with tournament and empty params if not provided' do
      service = Host::MatchService.new(tournament)
      expect(service.instance_variable_get(:@tournament)).to eq(tournament)
      expect(service.instance_variable_get(:@params)).to eq({})
    end
  end

  describe '#list_matches' do
    it 'lists matches in ascending order of scheduled_at' do
      match1 = create(:match, tournament: tournament, scheduled_at: 2.days.from_now)
      match2 = create(:match, tournament: tournament, scheduled_at: 1.day.from_now)
      service = Host::MatchService.new(tournament)
      expect(service.list_matches).to eq([ match2, match1 ])
    end

    it 'returns an empty array when no matches are present' do
      empty_tournament = create(:tournament)
      service = Host::MatchService.new(empty_tournament)
      expect(service.list_matches).to eq([])
    end
  end

  describe '#find_match' do
    it 'finds a match by id' do
      service = Host::MatchService.new(tournament)
      found_match = service.find_match(match.id)
      expect(found_match).to eq(match)
    end

    it 'raises ActiveRecord::RecordNotFound when match does not exist' do
      service = Host::MatchService.new(tournament)
      expect { service.find_match(999) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
  describe '#create_match' do
    it 'creates a new match with valid params' do
      service = Host::MatchService.new(tournament, params)
      result = service.create_match
      expect(result[:success]).to be true
      expect(result[:match].scheduled_at).to eq(params[:scheduled_at])
      expect(result[:match].location).to eq(params[:location])
      expect(tournament.matches.count).to eq(1)
    end

    it 'returns errors when params are invalid' do
      invalid_params = { scheduled_at: nil, location: nil }
      service = Host::MatchService.new(tournament, invalid_params)
      result = service.create_match
      expect(result[:success]).to be false
      expect(result[:errors]).not_to be_empty
      expect(tournament.matches.count).to eq(0)
    end

    it 'creates a match with minimal valid parameters' do
        minimal_params = { scheduled_at: 1.day.from_now }
        service = Host::MatchService.new(tournament, minimal_params)
        result = service.create_match
        expect(result[:success]).to be true
        expect(result[:match].scheduled_at).to eq(minimal_params[:scheduled_at])
    end

    it 'returns errors for incorrect data types' do
      invalid_types = { scheduled_at: "not a date", location: 123 }
      service = Host::MatchService.new(tournament, invalid_types)
      result = service.create_match
      expect(result[:success]).to be false
      expect(result[:errors]).not_to be_empty
    end
  end

  describe '#update_match' do
    it 'updates a match with valid params' do
      service = Host::MatchService.new(tournament, params)
      result = service.update_match(match)
      expect(result[:success]).to be true
      expect(result[:match].scheduled_at).to eq(params[:scheduled_at])
      expect(result[:match].location).to eq(params[:location])
      expect(match.reload.scheduled_at).to eq(params[:scheduled_at])
      expect(match.reload.location).to eq(params[:location])
    end

    it 'returns errors when params are invalid' do
      invalid_params = { scheduled_at: nil, location: nil }
      service = Host::MatchService.new(tournament, invalid_params)
      result = service.update_match(match)
      expect(result[:success]).to be false
      expect(result[:errors]).not_to be_empty
      expect(match.reload.location).not_to be_nil
    end

    it 'updates only the scheduled_at attribute' do
      new_scheduled_at = 2.days.from_now
      update_params = { scheduled_at: new_scheduled_at }
      service = Host::MatchService.new(tournament, update_params)
      result = service.update_match(match)
      expect(result[:success]).to be true
      expect(match.reload.scheduled_at).to eq(new_scheduled_at)
    end

    it 'updates only the location attribute' do
        new_location = "New Location"
        update_params = { location: new_location }
        service = Host::MatchService.new(tournament, update_params)
        result = service.update_match(match)
        expect(result[:success]).to be true
        expect(match.reload.location).to eq(new_location)
    end
  end


  describe '#delete_match' do
    it 'deletes a match' do
      service = Host::MatchService.new(tournament)
      result = service.delete_match(match)
      expect(result[:success]).to be true
      expect(tournament.matches.count).to eq(0)
    end

    it 'returns errors if deletion fails' do
      allow(match).to receive(:destroy).and_return(false)
      allow(match.errors).to receive(:full_messages).and_return([ 'Deletion failed' ])
      service = Host::MatchService.new(tournament)
      result = service.delete_match(match)
      expect(result[:success]).to be false
      expect(result[:errors]).to eq([ 'Deletion failed' ])
    end
  end
end
