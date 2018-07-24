require 'rails_helper'
RSpec.describe 'TeacherVacancyAuthorisation::Permissions' do
  let(:service) { TeacherVacancyAuthorisation::Permissions.new }
  let(:headers) { { 'Authorization' => 'Token token=test-token', 'Content-Type' => 'application/json' } }
  let(:request) { double(:request, path: '') }
  let(:mock_http) { double(:http, request: double(:reponse, code: '200', body: { user: { permissions: [] } }.to_json)) }

  before(:each) do
    stub_const('AUTHORISATION_SERVICE_URL', 'https://localhost:1357')
    stub_const('AUTHORISATION_SERVICE_TOKEN', 'test-token')
  end

  describe '#initialize' do
    it 'sets the correct headers' do
      expect(service.headers).to eq(headers)
    end
  end

  describe '#authorise' do
    it 'parses the returned result' do
      expect(Net::HTTP::Get).to receive(:new).with('/users/sample-token', headers).and_return(request)
      expect(Net::HTTP).to receive(:new).with('localhost', 1357).and_return(mock_http)
      expect(mock_http).to receive(:use_ssl=).with(true)

      expect(service.authorise('sample-token')).to eq([])
    end

    it 'does not parse the returned result if code is not 200' do
      mock_http = double(:http, request: double(:reponse, code: '505'))
      expect(Net::HTTP::Get).to receive(:new).with('/users/some invalid sample-token', headers).and_return(request)
      expect(Net::HTTP).to receive(:new).with('localhost', 1357).and_return(mock_http)
      expect(mock_http).to receive(:use_ssl=).with(true)

      expect(service.authorise('some invalid sample-token')).to eq([])
    end
  end

  describe '#school_urn' do
    it 'returns nil if no permissions are set for the given user token' do
      expect(Net::HTTP::Get).to receive(:new).with('/users/sample-token', headers).and_return(request)
      expect(Net::HTTP).to receive(:new).with('localhost', 1357).and_return(mock_http)
      expect(mock_http).to receive(:use_ssl=).with(true)

      service.authorise('sample-token')
      expect(service.school_urn).to eq(nil)
    end

    it 'returns the first school_urn for the user_token' do
      response = { user: { permissions: [{ school_urn: '12345' }] } }.to_json
      mock_http = double(:http, request: double(:reponse, code: '200', body: response))
      expect(mock_http).to receive(:use_ssl=).with(true)
      expect(Net::HTTP::Get).to receive(:new).with('/users/sample-token', headers).and_return(request)
      expect(Net::HTTP).to receive(:new).with('localhost', 1357).and_return(mock_http)

      service.authorise('sample-token')
      expect(service.school_urn).to eq('12345')
    end
  end

  describe '#many?' do
    it 'returns true if there are multiple schools that the user is authorised with' do
      response = { user: { permissions: [{ school_urn: '12345' }, { school_urn: '23412' }] } }.to_json
      mock_http = double(:http, request: double(:reponse, code: '200', body: response))

      expect(Net::HTTP::Get).to receive(:new).with('/users/sample-token', headers).and_return(request)
      expect(Net::HTTP).to receive(:new).with('localhost', 1357).and_return(mock_http)
      expect(mock_http).to receive(:use_ssl=).with(true)

      service.authorise('sample-token')
      expect(service.many?).to eq(true)
    end

    it 'returns false if there are multiple schools that the user is authorised with' do
      response = { user: { permissions: [{ school_urn: '12345' }] } }.to_json
      mock_http = double(:http, request: double(:reponse, code: '200', body: response))

      expect(Net::HTTP::Get).to receive(:new).with('/users/sample-token', headers).and_return(request)
      expect(Net::HTTP).to receive(:new).with('localhost', 1357).and_return(mock_http)
      expect(mock_http).to receive(:use_ssl=).with(true)

      service.authorise('sample-token')
      expect(service.many?).to eq(false)
    end
  end
end
