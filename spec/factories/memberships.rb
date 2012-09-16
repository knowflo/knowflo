# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :membership do
    association :group
    association :user
    role 'member'
  end

  factory :invitation, :class => :membership do
    association :group
    role 'member'
    invitation_email { FactoryGirl.generate :email }
    association :invited_by_user, :factory => :user
  end
end
