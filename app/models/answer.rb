class Answer < ActiveRecord::Base
  has_many :comments, :dependent => :destroy
  has_many :votes, :dependent => :destroy

  belongs_to :question, :counter_cache => true
  belongs_to :user

  validates :question_id, :presence => true
  validates :user_id,     :presence => true
  validates :body,        :presence => true

  validate :check_user_permissions
  validate :check_solution, :on => :create
  before_save :prevent_duplicate_solutions
  after_create :create_owner_vote

  delegate :group, :to => :question

  attr_protected :solution

  scope :solutions, where(:solution => true)

  def short_text
    body && body.size < 40 ? body : "#{body.try(:slice, 0, 37)}..."
  end

  def to_s
    "Answer ##{id}: #{short_text}"
  end

  def as_json(options)
    super(:only => [:user_id, :question_id, :body, :created_at, :updated_at],
          :methods => [:points])
  end

  def points
    update_points_cache if points_cache.blank?
    points_cache
  end

  def update_points_cache
    update_attribute(:points_cache, votes.sum(:value))
  end

  def vote_for(user)
    user_votes = votes.where(:user_id => user.id)
    if user_votes.any?
      user_votes.first.value
    else
      0
    end
  end

  def accepted?
    !!solution
  end

  private

  def check_user_permissions
    if user && question && group.private?
      errors.add(:user_id, 'is not authorized') unless group.users.include?(user)
    end
  end

  def check_solution
    errors.add(:solution, 'cannot be set') if solution && user != question.user
  end

  def prevent_duplicate_solutions
    question.answers.solutions.each do |ans|
      if ans.id != id
        ans.solution = false
        ans.save
      end
    end
  end

  def create_owner_vote
    votes.create(:user => user, :value => 1)
  end
end
