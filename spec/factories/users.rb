# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    first_name 'John'
    last_name 'Smith'
    email { FactoryGirl.generate :email }
    password 'password'
  end

  factory :admin_user, :parent => :user do
    admin true
  end

  factory :omniauth_user, :parent => :user do
    auth_provider 'facebook'
    auth_uid { FactoryGirl.generate :uid }
  end
end
