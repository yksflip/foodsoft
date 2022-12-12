require 'swagger_helper'

describe 'User', type: :request do
  include ApiHelper

  let(:api_scopes) { ['finance:user'] }
  let(:user) { create :user, groups: [create(:ordergroup)] }
  let(:other_user2) { create :user }
  let(:ft) { create(:financial_transaction, user: user, ordergroup: user.ordergroup) }

  before do
    ft
  end

  path '/user/financial_transactions' do
    post 'create new financial transaction (requires enabled self service)' do
      tags "Financial Transaction"
      consumes 'application/json'
      produces 'application/json'

      parameter name: :financial_transaction, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :integer },
          financial_transaction_type: { type: :integer },
          note: { type: :string }
        }
      }

      let(:financial_transaction) { { amount: 3, financial_transaction_type_id: create(:financial_transaction_type).id, note: 'lirum larum' } }

      response '200', 'success' do
        schema type: :object, properties: {
          financial_transaction: { '$ref': '#/components/schemas/FinancialTransaction' }
        }
        run_test!
      end

      it_handles_invalid_token_with_id :financial_transaction
      it_handles_invalid_scope_with_id(:financial_transaction, 'user has no ordergroup, is below minimum balance, self service is disabled, or missing scope')

      response '404', 'financial transaction type not found' do
        schema '$ref' => '#/components/schemas/Error404'
        let(:financial_transaction) { { amount: 3, financial_transaction_type_id: 'invalid', note: 'lirum larum' } }
        run_test!
      end

      # TODO: fix controller to actually send a 422 for invalid params?
      # Expected response code '200' to match '422'
      # Response body: {"financial_transaction":{"id":316,"user_id":599,"user_name":"Lisbeth ","amount":-3.0,"note":"-2","created_at":"2022-12-12T13:05:32.000+01:00","financial_transaction_type_id":346,"financial_transaction_type_name":"aut est iste #9"}}
      #
      # response '422', 'invalid parameter value' do
      #   # schema '$ref' => '#/components/schemas/Error422'
      #   let(:financial_transaction) { { amount: -3, financial_transaction_type_id: create(:financial_transaction_type).id, note: -2 } }
      #   run_test!
      # end
    end

    get "financial transactions of the member's ordergroup" do
      tags 'User', 'Financial Transaction'
      produces 'application/json'
      parameter name: "per_page", in: :query, type: :integer, required: false
      parameter name: "page", in: :query, type: :integer, required: false


      response '200', 'success' do
        schema type: :object, properties: {
          meta: { '$ref': '#/components/schemas/Meta' },
          financial_transaction: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['financial_transactions'].first['id']).to eq(ft.id)
        end
      end

      it_handles_invalid_token_and_scope
    end
  end

  path '/user/financial_transactions/{id}' do
    get 'find financial transaction by id' do
      tags 'User', 'Financial Transaction'
      produces 'application/json'
      id_url_param

      response '200', 'success' do
        schema type: :object, properties: {
          financial_transaction: {
            type: :object,
            items: {
              '$ref': '#/components/schemas/FinancialTransaction'
            }
          }
        }
        let(:id) { ft.id }
        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['financial_transaction']['id']).to eq(ft.id)
        end
      end

      it_handles_invalid_token_with_id :financial_transaction
      it_handles_invalid_scope_with_id :financial_transaction, 'user has no ordergroup or missing scope'
      it_cannot_find_object 'financial transaction not found'
    end
  end
end
