# frozen_string_literal: true

# spec/support/spec_test_helper.rb
module SpecTestHelper
  def login_admin
    login(:admin)
  end

  def login(user)
    user = User.where(:nick => user.nick).first if user.is_a?(Symbol)
    session[:user_id] = user.id
    session[:scope] = FoodsoftConfig[:default_scope] # Save scope in session to not allow switching between foodcoops with one account
    session[:locale] = user.locale
  end


  def current_user
    User.find(session[:user_id])
  end
end

# spec/spec_helper.rb
RSpec.configure do |config|
  config.include SpecTestHelper, :type => :controller
end
