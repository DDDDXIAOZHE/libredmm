require 'rails_helper'

RSpec.describe VotesController, type: :routing do
  describe 'routing' do
    it 'routes to #update' do
      expect(:put => '/movies/CODE-001/vote').to route_to('votes#update', movie_id: 'CODE-001')
    end

    it 'routes to #destroy' do
      expect(:delete => '/movies/CODE-001/vote').to route_to('votes#destroy', movie_id: 'CODE-001')
    end
  end
end
