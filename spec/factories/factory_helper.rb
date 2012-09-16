FactoryGirl.define do
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :uid do |n|
    "100#{n}"
  end

  sequence :name do |n|
    "User #{n}"
  end
end
