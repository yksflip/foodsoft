require 'swagger_helper'

describe 'Navigation API', type: :request do
  include ApiHelper

  path '/navigation' do
    get 'navigation' do
      tags 'General'
      produces 'application/json'
      let(:api_scopes) { ['config:user'] }

      response '200', 'success' do
        schema type: :object, properties: {
          navigation: {
            '$ref' => '#/components/schemas/Navigation'
          }
        }

        run_test!
      end

      it_handles_invalid_token
    end
  end
end
