# frozen_string_literal: true

require 'spec_helper'

describe HomeController do
  describe "GET profile" do
    it 'shows dashboard for logged in user' do
      get :my_profile
      expect(response).to have_http_status(:success)
    end
  end
end
