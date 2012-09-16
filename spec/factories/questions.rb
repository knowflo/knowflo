# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    association :user
    association :group
    subject "Who is the fairest of them all?"
    body "Really need to know. Very important."
  end
end
