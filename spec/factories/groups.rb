# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    name 'My Group'

    factory :private_group_with_questions do
      privacy 'private'

      ignore do
        questions_count 2
      end

      after_create do |group, evaluator|
        user = FactoryGirl.create(:membership, :group => group, :role => 'admin').user
        FactoryGirl.create_list(:question, evaluator.questions_count, :group => group, :user => user)
      end
    end
  end
end
