require_relative '../spec_helper'

feature 'supplier' do
  let(:supplier) { create :supplier }
  let(:user) { create :user, groups: [create(:workgroup, role_suppliers: true)] }

  before { login user }

  describe 'create new' do
    it 'can be created' do
      create :supplier_category
      visit suppliers_path
      click_on I18n.t('suppliers.index.action_new')
      supplier = build :supplier
      within('#new_supplier') do
        fill_in 'supplier_name', :with => supplier.name
        fill_in 'supplier_address', :with => supplier.address
        fill_in 'supplier_phone', :with => supplier.phone
        find('input[type="submit"]').click
      end
      expect(page).to have_content(supplier.name)
    end

    it 'is included in supplier list' do
      supplier
      visit suppliers_path
      expect(page).to have_content(supplier.name)
    end
  end

  describe 'existing', js: true do
    it 'can be shown' do
      supplier
      visit suppliers_path
      click_link supplier.name
      expect(page).to have_content(supplier.address)
      expect(page).to have_content(supplier.phone)
      expect(page).to have_content(supplier.email)
    end

    it 'can be updated' do
      new_name = Faker::Company.name.truncate(30)
      supplier
      visit suppliers_path
      click_link I18n.t('ui.edit')
      fill_in I18n.t('activerecord.attributes.supplier.name'), with: new_name
      click_button 'Update Supplier'
      expect(supplier.reload.name).to eq new_name
    end

    it 'can be destroyed' do
      supplier
      visit suppliers_path
      expect(page).to have_content(supplier.name)
      accept_confirm do
        click_link I18n.t('ui.delete')
      end
      expect(page).not_to have_content(supplier.name)
      expect(supplier.reload.deleted?).to be true
    end
  end
end
