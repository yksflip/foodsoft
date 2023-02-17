require_relative '../../../../spec/spec_helper'

feature 'messages' do
  let(:sending_user) { create :user }
  let(:receiving_user) { create :user }
  let(:message){ create :message }
  before {
    login sending_user
    message.add_recipients([receiving_user])
  }
  describe 'index' do
    before { visit messages_path }

    it 'shows subject of message' do
      expect(page).to have_content 'New message'
      expect(page).to have_content message.subject
    end

    it 'can open message when clicked on subject' do
      click_link(message.subject)
      expect(page).to have_content message.body.to_plain_text
    end
  end

  describe 'create new', js: true do
    before {
      login sending_user
      visit new_message_path
    }
    after { page.save_screenshot('screenshot.png') }

    # TODO: fix trix-editor stuff
    # https://stackoverflow.com/questions/45962746/rails-capybara-populate-hidden-field-from-trix-editor
    it 'shows input elements' do
      choose 'Send to all members'
      fill_in 'message_subject', with: 'hello friend'
      # print page.body()
      expect(page).to have_selector('trix-editor')
      foo = find('#message_body_trix_input_message', visible: false)
      puts foo.inspect
      editor = find('trix-editor')
      editor.click.set('foo bar 123')
      # find('.message_body', visible: false).set("some value here")
      click_button 'send message'
      expect(page).to have_current_path(messages_path)
      expect(page).to have_selector '.alert-success'
      expect(page).to have_content 'hello friend'
    end
  end
end
