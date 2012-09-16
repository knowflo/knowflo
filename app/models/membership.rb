class Membership < ActiveRecord::Base
  ROLE_OPTIONS = ['member', 'admin']

  include TokenGenerator

  belongs_to :invited_by_user, :class_name => 'User'
  belongs_to :user
  belongs_to :group

  validates :group_id, :presence => true
  validates :role,     :presence => true, :inclusion => { :in => ROLE_OPTIONS }

  validates :invitation_email, :uniqueness => { :scope => :group_id },
                               :email_format => true,
                               :if => :new_user_invitation?
  validate :check_recipient

  before_validation :set_defaults,   :on => :create
  before_validation :generate_token, :on => :create

  def to_param
    token
  end

  private

  def new_user_invitation?
    user.blank?
  end

  def set_defaults
    self.role ||= 'member'
  end

  def check_recipient
    if user_id.blank? && invitation_email.blank?
      errors.add(:invitation_email, "cannot be blank")
    end
  end
end
