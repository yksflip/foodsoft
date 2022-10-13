# frozen_string_literal: true

require 'spec_helper'

class DummyAuthController < ApplicationController; end

describe 'Auth concern', type: :controller do
  controller DummyAuthController do
    # Defining a dummy action for an anynomous controller which inherits from the described class.
    def authenticate_blank
      authenticate
    end

    def authenticate_unknown_group
      authenticate('nooby')
    end

    def authenticate_pickups
      authenticate('pickups')
      head :ok unless performed?
    end

    def authenticate_finance_or_orders
      authenticate('finance_or_orders')
      head :ok unless performed?
    end

    def try_authenticate_membership_or_admin
      authenticate_membership_or_admin
    end

    def try_authenticate_or_token
      authenticate_or_token('xyz')
      head :ok unless performed?
    end
  end

  # unit testing protected/private methods
  describe 'protected/private methods' do
    let(:user) { create :user }

    describe '#current_user' do
      before { login user }

      describe 'with valid session' do
        it "returns current_user" do
          subject.session[:user_id] = user.id
          subject.params[:foodcoop] = FoodsoftConfig[:default_scope]
          expect(subject.send(:current_user)).to eq user
          expect(assigns(:current_user)).to eq user
        end
      end

      describe 'with invalid session' do
        it "not returns current_user" do
          subject.session[:user_id] = ''
          subject.params[:foodcoop] = FoodsoftConfig[:default_scope]
          expect(subject.send(:current_user)).to be_nil
          expect(assigns(:current_user)).to be_nil
        end
      end
    end

    describe '#deny_access' do
      xit "redirects to root_url" do
        expect(subject.send(:deny_access)).to redirect_to(root_url)
      end
    end

    describe '#login' do
      it "sets user in session" do
        subject.send(:login, user)
        expect(subject.session[:user_id]).to eq user.id
        expect(subject.session[:scope]).to eq FoodsoftConfig.scope
        expect(subject.session[:locale]).to eq user.locale
      end
    end

    describe '#login_and_redirect_to_return_to' do
      xit "redirects to already set target" do
        subject.session[:return_to] = my_profile_url
        subject.send(:login_and_redirect_to_return_to, user)
        expect(subject.session[:return_to]).to be nil
      end
    end
  end

  describe 'authenticate' do
    describe 'not logged in' do
      it 'does not authenticate' do
        routes.draw { get "authenticate_blank" => "dummy_auth#authenticate_blank" }
        get :authenticate_blank, params: { foodcoop: FoodsoftConfig[:default_scope] }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(login_path)
        expect(flash[:alert]).to match(I18n.t('application.controller.error_authn'))
      end
    end

    describe 'logged in' do
      let(:user) { create :user }
      let(:pickups_user) { create :user, :role_pickups }
      let(:finance_user) { create :user, :role_finance }
      let(:orders_user) { create :user, :role_orders }

      it 'does not authenticate with unknown group' do
        login user
        routes.draw { get "authenticate_unknown_group" => "dummy_auth#authenticate_unknown_group" }
        get :authenticate_unknown_group, params: { foodcoop: FoodsoftConfig[:default_scope] }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(I18n.t('application.controller.error_denied', sign_in: ActionController::Base.helpers.link_to(I18n.t('application.controller.error_denied_sign_in'), login_path)))
      end

      it 'does not authenticate with pickups group' do
        login pickups_user
        routes.draw { get "authenticate_pickups" => "dummy_auth#authenticate_pickups" }
        get :authenticate_pickups, params: { foodcoop: FoodsoftConfig[:default_scope] }
        expect(response).to have_http_status(:success)
      end

      it 'does not authenticate with finance group' do
        login finance_user
        routes.draw { get "authenticate_finance_or_orders" => "dummy_auth#authenticate_finance_or_orders" }
        get :authenticate_finance_or_orders, params: { foodcoop: FoodsoftConfig[:default_scope] }
        expect(response).to have_http_status(:success)
      end

      it 'does not authenticate with orders group' do
        login orders_user
        routes.draw { get "authenticate_finance_or_orders" => "dummy_auth#authenticate_finance_or_orders" }
        get :authenticate_finance_or_orders, params: { foodcoop: FoodsoftConfig[:default_scope] }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'authenticate_membership_or_admin' do
    describe 'logged in' do
      let(:pickups_user) { create :user, :role_pickups }
      let(:workgroup) { create :workgroup }

      it 'redirects with not permitted group' do
        group_id = workgroup.id
        login pickups_user
        routes.draw { get "try_authenticate_membership_or_admin" => "dummy_auth#try_authenticate_membership_or_admin" }
        get :try_authenticate_membership_or_admin, params: { foodcoop: FoodsoftConfig[:default_scope], id: group_id }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(I18n.t('application.controller.error_members_only'))
      end
    end
  end

  describe 'authenticate_or_token' do
    describe 'logged in' do
      let(:token_verifier) { TokenVerifier.new('xyz') }
      let(:token_msg) { token_verifier.generate }
      let(:user) { create :user }

      it 'authenticates token' do
        login user
        routes.draw { get "try_authenticate_or_token" => "dummy_auth#try_authenticate_or_token" }
        get :try_authenticate_or_token, params: { foodcoop: FoodsoftConfig[:default_scope], token: token_msg }
        expect(response).to_not have_http_status(:redirect)
      end

      it 'redirects on faulty token' do
        login user
        routes.draw { get "try_authenticate_or_token" => "dummy_auth#try_authenticate_or_token" }
        get :try_authenticate_or_token, params: { foodcoop: FoodsoftConfig[:default_scope], token: 'abc' }
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to match(I18n.t('application.controller.error_token'))
      end

      it 'authenticates current user on empty token' do
        login user
        routes.draw { get "try_authenticate_or_token" => "dummy_auth#try_authenticate_or_token" }
        get :try_authenticate_or_token, params: { foodcoop: FoodsoftConfig[:default_scope] }
        expect(response).to have_http_status(:success)
      end
    end
  end
end