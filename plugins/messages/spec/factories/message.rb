require 'factory_bot'

FactoryBot.define do
  factory :message do
    sender {create :user}
    subject {  Faker::Lorem.words(number: 7) }
    body { Faker::Lorem.words(number: 42)}
    created_at {Time.now}
    private { false }
    send_method { 'recipients' }
  end
end