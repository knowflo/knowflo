class Comment < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user

  validates :answer_id, :presence => true
  validates :user_id,   :presence => true
  validates :body,      :presence => true

  validate :check_user_permissions

  delegate :question, :to => :answer
  delegate :group, :to => :answer

  def short_text
    body && body.size < 40 ? body : "#{body.try(:slice, 0, 37)}..."
  end

  def to_s
    "Comment ##{id}: #{short_text}"
  end

  private

  def check_user_permissions
    if user && answer && group.private?
      errors.add(:user_id, 'is not authorized') unless group.users.include?(user)
    end
  end
end
