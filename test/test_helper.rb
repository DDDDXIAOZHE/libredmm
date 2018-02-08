require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock/minitest'

WebMock.disable_net_connect!(allow_localhost: true)

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  setup do
    @api_stub = stub_request(:any, /api\.libredmm\.com\/search\?q=/).to_return(
      body: lambda { |request|
        {
          code: request.uri.query_values['q'],
        }.to_json
      },
    )
  end
end
