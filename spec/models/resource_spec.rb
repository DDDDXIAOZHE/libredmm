require 'rails_helper'

RSpec.describe Resource, type: :model do
  context 'creating' do
    it 'rejects empty movie' do
      expect {
        create(:resource, movie: nil)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'rejects unsaved movie' do
      expect {
        create(:resource, movie: build(:movie))
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

  context 'scope' do
    describe 'in_baidu_pan' do
      it 'includes only resources with pan.baidu.com in url' do
        baidu_pan_resource = create :resource, download_uri: 'http://pan.baidu.com/s/xxx'
        create :resource
        expect(Resource.in_baidu_pan.all).to eq([baidu_pan_resource])
      end
    end

    describe 'in_bt' do
      it 'includes only resources with url ends with .torrent' do
        bt_resource = create :resource, download_uri: 'http://www.libredmm.com/xxx.torrent'
        create :resource
        expect(Resource.in_bt.all).to eq([bt_resource])
      end
    end
  end
end
