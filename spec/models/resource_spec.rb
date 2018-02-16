require 'rails_helper'

RSpec.describe Resource, type: :model do
  context 'creating' do
    it 'requires movie' do
      expect {
        create(:resource, movie: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires download_uri' do
      expect {
        create(:resource, download_uri: '')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'rejects duplicate download_uri' do
      resource = create :resource
      expect {
        create(:resource, download_uri: resource.download_uri)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'rejects download_uri not in uri format' do
      expect {
        create(:resource, download_uri: 'foobar')
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
