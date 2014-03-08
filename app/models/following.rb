class Following < ActiveRecord::Base
  belongs_to :user
  belongs_to :question

  validates :user_id, presence: true, uniqueness: { scope: :question_id }
  validates :question_id, presence: true
end
