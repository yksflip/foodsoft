# frozen_string_literal: true

require 'spec_helper'

describe ArticlesController, type: :controller do
  let(:user) { create :user, :role_article_meta }

  before { login user }

  describe 'GET index' do
    let(:article_categoryA) { create :article_category, name: "AAAA" }
    let(:article_categoryB) { create :article_category, name: "BBBB" }
    let(:articleA) { create :article, name: 'AAAA', note: "AAAA", unit: '250 g', article_category: article_categoryA, availability: false }
    let(:articleB) { create :article, name: 'BBBB', note: "BBBB", unit: '500 g', article_category: article_categoryB, availability: true }
    let(:supplier) { create :supplier, articles: [articleA, articleB] }

    it 'assigns sorting on articles' do
      sortings = [
        ['name', [articleA, articleB]],
        ['name_reverse', [articleB, articleA]],
        ['unit', [articleA, articleB]],
        ['unit_reverse', [articleB, articleA]],
        ['article_category', [articleA, articleB]],
        ['article_category_reverse', [articleB, articleA]],
        ['note', [articleA, articleB]],
        ['note_reverse', [articleB, articleA]],
        ['availability', [articleA, articleB]],
        ['availability_reverse', [articleB, articleA]]
      ]
      sortings.each do |sorting|
        get :index, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, sort: sorting[0] }
        expect(response).to have_http_status(:success)
        expect(assigns(:articles).to_a).to eq(sorting[1])
      end
    end
  end
end
