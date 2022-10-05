require_relative '../spec_helper'

feature HomeController do
  let(:user) { create :user }

  before { login user }

  describe 'my profile' do
    before { visit my_profile_path }

    it 'is accessible' do
      expect(page).to have_selector 'input[id=user_first_name]'
      expect(find_field('user_first_name').value).to eq(user.first_name)
    end

    it 'updates first name' do
      fill_in 'user_first_name', with: 'foo'
      click_button('Save')
      expect(User.find(user.id).first_name).to eq 'foo'
      expect(page).to have_selector '.alert-success'
    end
  end
end
