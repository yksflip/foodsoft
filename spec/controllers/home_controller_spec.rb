# frozen_string_literal: true

require 'spec_helper'

describe HomeController, type: :controller do
  let(:user) { create(:user) }

  describe "GET profile" do
    before do
      login user
    end

    it 'shows dashboard for logged in user' do
      get :profile, params: { foodcoop: FoodsoftConfig[:default_scope] }
      expect(response).to have_http_status(:success)
    end
  end
end
