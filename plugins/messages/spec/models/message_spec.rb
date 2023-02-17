require_relative '../../../../spec/spec_helper'

describe Message do

  let(:sender) { create :user }
  let(:receiver) { create :user }
  let(:another) { create :user }
  let(:message) { create :message,
                    sender: sender,
                    recipients: [receiver],
                    subject: 'hello friend',
                    body: 'hi how are you?',
                    private: false,
                    send_method: 'recipients'
  }

  it 'can be created' do
    expect(message.recipients).to eq([receiver])
    expect(message.subject).to eq('hello friend')
    expect(message.body.to_plain_text).to eq('hi how are you?')
    puts message.message_recipients.inspect

  end

  it 'can be private' do
    expect(message.is_readable_for?(receiver)).to be_truthy
    expect(message.is_readable_for?(sender)).to be_truthy
    expect(message.is_readable_for?(another)).to be_truthy
    message.update_attribute :private, true
    expect(message.is_readable_for?(another)).to be_falsey
  end

end