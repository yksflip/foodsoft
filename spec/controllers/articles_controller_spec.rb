# frozen_string_literal: true

require 'spec_helper'

describe ArticlesController, type: :controller do
  let(:user) { create :user, :role_article_meta }
  let(:article_categoryA) { create :article_category, name: "AAAA" }
  let(:article_categoryB) { create :article_category, name: "BBBB" }
  let(:articleA) { create :article, name: 'AAAA', note: "AAAA", unit: '250 g', article_category: article_categoryA, availability: false }
  let(:articleB) { create :article, name: 'BBBB', note: "BBBB", unit: '500 g', article_category: article_categoryB, availability: true }
  let(:articleC) { create :article, name: 'CCCC', note: "CCCC", unit: '500 g', article_category: article_categoryB, availability: true }

  let(:supplier) { create :supplier, articles: [articleA, articleB] }
  let(:order) { create :order }


  before { login user }

  describe 'GET index' do
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

    it 'triggers an article csv' do
      get :index, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id }, format: :csv
      expect(response.header["Content-Type"]).to include("text/csv")
      expect(response.body).to include(articleA.unit, articleB.unit)
    end
  end

  describe "new" do
    it 'renders form for a new article' do
      get :new, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id }, xhr: true
      expect(response).to have_http_status(:success)
    end
  end

  describe "copy" do
    it 'renders form with copy of an article' do
      get :copy, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, article_id: articleA.id }, xhr: true
      expect(assigns(:article).attributes).to eq(articleA.dup.attributes)
      expect(response).to have_http_status(:success)
    end
  end
  # TODO:

  describe "#create" do
    it 'creates a new article' do
      valid_attributes = articleA.attributes.except("id")
      valid_attributes["name"] = "ABAB"
      get :create, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, article: valid_attributes }, xhr: true
      expect(response).to have_http_status(:success)
    end

    it 'fails to create a new article and renders #new' do
      get :create, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, article: { id: nil } }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/new')
    end
  end

  describe "edit" do
    it 'opens form to edit article attributes' do
      get :edit, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, id: articleA.id }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/new')
    end
  end

  describe "#edit all" do
    it 'renders edit_all' do
      get :edit_all, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id }, xhr: true
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/edit_all')
    end
  end

  describe "#update" do
    it 'updates article attributes' do
      get :update, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, id: articleA.id, article: { unit: "300 g" } }, xhr: true
      expect(assigns(:article).unit).to eq("300 g")
      expect(response).to have_http_status(:success)
    end

    it 'updates article attributes' do
      get :update, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, id: articleA.id, article: { name: nil } }, xhr: true
      expect(response).to render_template('articles/new')
    end
  end

  describe "#update_all" do
    xit 'updates all articles' do
      # never used and controller method bugged
      get :update_all, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, articles: [articleA, articleB] }
      puts assigns(:articles).count
      expect(response).to have_http_status(:success)
    end
  end

  describe "#update_selected" do
    let(:order_article) { create :order_article, order: order, article: articleC }
    before do
      order_article
    end

    it 'updates selected articles' do
      get :update_selected, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, selected_articles: [articleA.id, articleB.id] }
      expect(response).to have_http_status(:redirect)
    end

    it 'destroys selected articles' do
      get :update_selected, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, selected_articles: [articleA.id, articleB.id], selected_action: "destroy" }
      articleA.reload
      articleB.reload
      expect(articleA.deleted? && articleB.deleted?).to be_truthy
      expect(response).to have_http_status(:redirect)
    end

    it 'sets availability false on selected articles' do
      get :update_selected, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, selected_articles: [articleA.id, articleB.id], selected_action: "setNotAvailable" }
      articleA.reload
      articleB.reload
      expect(articleA.availability || articleB.availability).to be_falsey
      expect(response).to have_http_status(:redirect)
    end

    it 'sets availability true on selected articles' do
      get :update_selected, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, selected_articles: [articleA.id, articleB.id], selected_action: "setAvailable" }
      articleA.reload
      articleB.reload
      expect(articleA.availability && articleB.availability).to be_truthy
      expect(response).to have_http_status(:redirect)
    end

    it 'fails deletion if one article is in open order' do
      get :update_selected, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, selected_articles: [articleA.id, articleC.id], selected_action: "destroy" }
      articleA.reload
      articleC.reload
      expect(articleA.deleted? || articleC.deleted?).to be_falsey
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "#parse_upload" do
    # let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/upload_test.csv')) }

    # before do
    #   file
    # end
    # TODO: Cannot use Rack attributes in controller??
    # #<NoMethodError: undefined method `original_filename' for
    # "#<Rack::Test::UploadedFile:0x00005575cef1d238>":String

    xit 'updates particles from spreadsheet' do
      get :parse_upload, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, articles: { file: file, outlist_absent: "1", convert_units: "1" } }
      # {articleA.id => articleA, articleB.id => articleB}}
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "#sync" do
    # TODO: double render error in controller
    xit 'updates particles from spreadsheet' do
      get :sync, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id }
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "#destroy" do
    let(:order_article) { create :order_article, order: order, article: articleC }
    before do
      order_article
    end

    it 'does not delete article if order open' do
      get :destroy, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, id: articleC.id }, xhr: true
      expect(assigns(:article).deleted?).to be_falsey
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/destroy')
    end

    it 'deletes article if order closed' do
      get :destroy, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, id: articleB.id }, xhr: true
      expect(assigns(:article).deleted?).to be_truthy
      expect(response).to have_http_status(:success)
      expect(response).to render_template('articles/destroy')
    end
  end

  describe "#update_synchronized" do
    let(:order_article) { create :order_article, order: order, article: articleC }
    before do
      order_article
      articleA
      articleB
      articleC
    end

    it 'deletes articles' do
      # TODO: double render error in controller
      get :update_synchronized, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, outlisted_articles: { articleA.id => articleA, articleB.id => articleB } }
      articleA.reload
      articleB.reload
      expect(articleA.deleted? && articleB.deleted?).to be_truthy
      expect(response).to have_http_status(:redirect)
    end

    it 'updates articles' do
      get :update_synchronized, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, articles: { articleA.id => { name: "NewNameA" }, articleB.id => { name: "NewNameB" } } }
      expect(assigns(:updated_articles).first.name).to eq "NewNameA"
      expect(response).to have_http_status(:redirect)
    end

    it 'does not update articles if article with same name exists' do
      get :update_synchronized, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier.id, articles: { articleA.id => { unit: "2000 g" }, articleB.id => { name: "AAAA" } } }
      error_array = [assigns(:updated_articles).first.errors.first, assigns(:updated_articles).last.errors.first]
      expect(error_array).to include(ActiveModel::Error)
      expect(response).to have_http_status(:success)
    end

    it 'does update articles if article with same name was deleted before' do
      get :update_synchronized, params: {
        foodcoop: FoodsoftConfig[:default_scope],
        supplier_id: supplier.id,
        outlisted_articles: { articleA.id => articleA },
        articles: {
          articleA.id => { name: "NewName" },
          articleB.id => { name: "AAAA" }
        }
      }
      error_array = [assigns(:updated_articles).first.errors.first, assigns(:updated_articles).last.errors.first]
      expect(error_array.any?).to be_falsey
      expect(response).to have_http_status(:redirect)
    end

    it 'does not delete articles in open order' do
      get :update_synchronized, params: {
        foodcoop: FoodsoftConfig[:default_scope],
        supplier_id: supplier.id,
        outlisted_articles: { articleC.id => articleC }
      }
      articleC.reload
      expect(articleC.deleted?).to be_falsey
      expect(response).to have_http_status(:success)
    end

    it 'assigns updated article_pairs on error' do
      get :update_synchronized, params: {
        foodcoop: FoodsoftConfig[:default_scope],
        supplier_id: supplier.id,
        articles: { articleA.id => { name: "DDDD" } },
        outlisted_articles: { articleC.id => articleC }
      }
      expect(assigns(:updated_article_pairs).first).to eq([articleA, { name: "DDDD" }])
      articleC.reload
      expect(articleC.deleted?).to be_falsey
      expect(response).to have_http_status(:success)
    end

    it 'updates articles in open order' do
      get :update_synchronized, params: {
        foodcoop: FoodsoftConfig[:default_scope],
        supplier_id: supplier.id,
        articles: { articleC.id => { name: "DDDD" } }
      }
      articleC.reload
      expect(articleC.name).to eq "DDDD"
      expect(response).to have_http_status(:redirect)
    end
  end

  describe "#shared" do
    let(:shared_supplier) { create :shared_supplier, shared_articles: [shared_article] }
    let(:shared_article) { create :shared_article, name: "shared" }
    let(:articleS) { create :article, name: 'SSSS', note: "AAAA", unit: '250 g', article_category: article_categoryA, availability: false }

    let(:supplier_with_shared) { create :supplier, articles: [articleS], shared_supplier: shared_supplier }

    it 'renders view with articles' do
      get :shared, params: { foodcoop: FoodsoftConfig[:default_scope], supplier_id: supplier_with_shared.id, name_cont_all_joined: "shared" }, xhr: true
      expect(assigns(:supplier).shared_supplier.shared_articles.any?).to be_truthy
      expect(assigns(:articles).any?).to be_truthy
      expect(response).to have_http_status(:success)
    end
  end

  describe "#import" do
    let(:shared_supplier) { create :shared_supplier, shared_articles: [shared_article] }
    let(:shared_article) { create :shared_article, name: "shared" }

    before do
      shared_article
      article_categoryA
    end

    it 'fills form with article details' do
      get :import, params: { foodcoop: FoodsoftConfig[:default_scope], article_category_id: article_categoryB.id, direct: "true", supplier_id: supplier.id, shared_article_id: shared_article.id }, xhr: true
      expect(assigns(:article).nil?).to be_falsey
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:create)
    end
    it 'does redirect to :new if param :direct not set' do
      get :import, params: { foodcoop: FoodsoftConfig[:default_scope], article_category_id: article_categoryB.id, supplier_id: supplier.id, shared_article_id: shared_article.id }, xhr: true
      expect(assigns(:article).nil?).to be_falsey
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)
    end
  end
end
