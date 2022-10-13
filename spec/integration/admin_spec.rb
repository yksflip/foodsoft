require_relative '../spec_helper'

feature Admin::BaseController do
  let(:admin) { create :admin }
  let(:users) { create_list :user, 2 }
  let(:workgroups) { create_list :workgroup, 3 }
  let(:groups) { create_list :group, 4 }

  before { login admin }

  describe 'base#index' do
    before do
      users
    end

    it 'is accessible with workgroups existing' do
      workgroups
      visit admin_root_path
      expect(page).to have_content(I18n.t('admin.base.index.newest_users'))
      expect(page).to have_content(users.first.name)
    end

    # TODO:
    it 'raising error when groups existing' do
      groups
      expect{ visit admin_root_path }.to raise_error(ActionView::Template::Error)
    end
  end
end
