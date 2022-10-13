require 'factory_bot'

FactoryBot.define do
    factory :delivery do
        supplier { create :supplier }
        invoice { create :invoice }
        date { Faker::Date.backward(days: 14) }
    end
end