class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  validates :group_id, :presence => true
  validates :user_id,  :presence => true
  validates :subject,  :presence => true
  validates :url,      :presence => true, :uniqueness => { :scope => :group_id }

  before_validation :set_defaults, :on => :create
  validate :check_user_permissions

  # NOTE: this has to come after set defaults are set, due to the order of validations
  acts_as_url :subject, :scope => :group_id

  def to_param
    "#{id}-#{url}"
  end

  def to_s
    "Message ##{id}: #{subject}"
  end

  def as_json(options=nil)
    serializable_hash({:methods => ["depth", "parent_id"] })
  end

  private

  def set_defaults
    if parent || parent_id
      self.subject = parent.subject if subject.blank?
      self.group = parent.group
    end
  end

  def check_user_permissions
    if user && group && group.private?
      errors.add(:user_id, 'is not authorized') unless group.users.include?(user)
    end
  end
end
