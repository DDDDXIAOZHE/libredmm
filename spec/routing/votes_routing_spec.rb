require 'rails_helper'

RSpec.describe VotesController, type: :routing do
  describe 'routing' do
    it 'routes to #update' do
      expect(put: '/movies/CODE-001/vote').to route_to(
        'votes#update', movie_code: 'CODE-001'
      )
    end

    it 'routes to #destroy' do
      expect(delete: '/movies/CODE-001/vote').to route_to(
        'votes#destroy', movie_code: 'CODE-001'
      )
    end

    it 'routes to #index' do
      expect(get: '/users/foo@bar.com/votes.codes').to route_to(
        'votes#index', user_email: 'foo@bar.com'
      )
      expect(get: '/users/foo@bar.com/votes.user.js').to route_to(
        'votes#index', user_email: 'foo@bar.com'
      )
    end
  end
end
