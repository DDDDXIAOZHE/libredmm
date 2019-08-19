# frozen_string_literal: true

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
    describe 'with_tag' do
      it 'works' do
        resource = create :resource, tags: %w[TAG 标签]
        expect(Resource.with_tag('标签')).to include(resource)
      end

      it 'ignores partial matches' do
        resource = create :resource, tags: %w[长标签]
        expect(Resource.with_tag('标签')).not_to include(resource)
      end
    end

    describe 'in_baidu_pan' do
      it 'includes resources with baidu pan url' do
        resource = create :resource, download_uri: generate(:baidu_pan_uri)
        expect(Resource.in_baidu_pan).to include(resource)
      end

      it 'exclude other resources' do
        resource = create :resource
        expect(Resource.in_baidu_pan).not_to include(resource)
      end
    end

    describe 'in_bt' do
      it 'includes resources with .torrent url' do
        resource = create :resource, download_uri: generate(:torrent_uri)
        expect(Resource.in_bt).to include(resource)
      end

      it 'exclude other resources' do
        resource = create :resource
        expect(Resource.in_baidu_pan).not_to include(resource)
      end
    end

    describe 'not_voted_by' do
      it 'includes resources of movies without vote' do
        user = create :user
        resource = create :resource
        expect(Resource.not_voted_by(user)).to include(resource)
      end

      it 'excludes resources of voted movies' do
        user = create :user
        resource = create :resource
        create :vote, user: user, movie: resource.movie
        expect(Resource.not_voted_by(user)).not_to include(resource)
      end

      it 'includes resources of movies only voted by other' do
        user = create :user
        resource = create :resource
        create :vote, movie: resource.movie
        expect(Resource.not_voted_by(user)).to include(resource)
      end

      it 'excludes resources of movies also voted by other' do
        user = create :user
        resource = create :resource
        create :vote, user: user, movie: resource.movie
        create :vote, movie: resource.movie
        expect(Resource.not_voted_by(user)).not_to include(resource)
      end

      it 'nil includes resources of movies without votes' do
        resource = create :resource
        expect(Resource.not_voted_by(nil)).to include(resource)
      end

      it 'nil includes resources of voted movies' do
        resource = create :resource
        create :vote, movie: resource.movie
        expect(Resource.not_voted_by(nil)).to include(resource)
      end
    end
  end
end
