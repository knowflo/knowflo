# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    association :answer
    association :user
    body "Thanks for the information; very helpful."
  end
end
