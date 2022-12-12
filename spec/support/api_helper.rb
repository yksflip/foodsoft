module ApiHelper
  extend ActiveSupport::Concern

  included do
    let(:user) { create(:user) }
    let(:api_scopes) { [] } # empty scopes for stricter testing (in reality this would be default_scopes)
    let(:api_access_token) { create(:oauth2_access_token, resource_owner_id: user.id, scopes: api_scopes&.join(' ')).token }
    let(:Authorization) { "Bearer #{api_access_token}" }

    def self.it_handles_invalid_token
      context 'with invalid access token' do
        let(:Authorization) { 'abc' }

        response 401, 'not logged-in' do
          schema '$ref' => '#/components/schemas/Error401'
          run_test!
        end
      end
    end

    def self.it_handles_invalid_token_with_id(class_sym)
      context 'with invalid access token' do
        let(:Authorization) { 'abc' }
        let(:id) { create(class_sym).id }

        response 401, 'not logged-in' do
          schema '$ref' => '#/components/schemas/Error401'
          run_test!
        end
      end
    end

    def self.it_handles_invalid_scope(description = 'missing scope')
      context 'with invalid scope' do
        let(:api_scopes) { ['none'] }

        response 403, description do
          schema '$ref' => '#/components/schemas/Error403'
          run_test!
        end
      end
    end

    def self.it_handles_invalid_scope_with_id(class_sym, description = 'missing scope')
      context 'with invalid scope' do
        let(:api_scopes) { ['none'] }
        let(:id) { create(class_sym).id }

        response 403, description do
          schema '$ref' => '#/components/schemas/Error403'
          run_test!
        end
      end
    end

    def self.it_cannot_find_object(description = 'not found')
      let(:id) { 'invalid' }


      response 404, description do
        schema '$ref' => '#/components/schemas/Error404'
        run_test!
      end
    end

    def self.it_handles_invalid_token_and_scope(*args)
      it_handles_invalid_token(*args)
      it_handles_invalid_scope(*args)
    end

    def self.id_url_param
      parameter name: :id, in: :path, type: :integer, required: true
    end
  end
end
