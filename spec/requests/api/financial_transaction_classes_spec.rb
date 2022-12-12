require 'swagger_helper'

describe 'Financial Transaction Classes', type: :request do
  include ApiHelper

  path '/financial_transaction_classes' do
    get 'financial transaction classes' do
      tags 'Category'
      produces 'application/json'
      parameter name: "per_page", in: :query, type: :integer, required: false
      parameter name: "page", in: :query, type: :integer, required: false
      let(:financial_transaction_class) { create(:financial_transaction_class) }

      response '200', 'success' do
        schema type: :object, properties: {
          meta: {
            '$ref' => '#/components/schemas/Meta'
          },
          financial_transaction_class: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionClass'
            }
          }
        }

        run_test!
      end

      it_handles_invalid_token
    end
  end

  path '/financial_transaction_classes/{id}' do
    get 'Retrieves a financial transaction class' do
      tags 'Category'
      produces 'application/json'
      id_url_param

      response '200', 'financial transaction class found' do
        schema type: :object, properties: {
          financial_transaction_classes: {
            type: :array,
            items: {
              '$ref': '#/components/schemas/FinancialTransactionClass'
            }
          }
        }
        let(:id) { create(:financial_transaction_class).id }
        run_test!
      end

      it_handles_invalid_token_with_id :financial_transaction
      it_cannot_find_object 'financial transaction class not found'
    end
  end
end
