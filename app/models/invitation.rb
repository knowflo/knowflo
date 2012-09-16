class Invitation < ActiveRecord::Base
  ROLE_OPTIONS = ['admin', 'member']
  include TokenGenerator

  attr_accessible :email, :role, :group_id, :source_user_id

  belongs_to :source_user, :class_name => 'User'
  belongs_to :recipient_user, :class_name => 'User'
  belongs_to :group

  validates :email,          :uniqueness => { :scope => :group_id }, :email_format => true
  validates :source_user_id, :presence => true
  validates :group_id,       :presence => true
  validates :role,           :presence => true, :inclusion => { :in => ROLE_OPTIONS }

  validate :check_recipient

  before_validation :generate_tokens, :on => :create
  before_validation :set_defaults, :on => :create

  def to_param
    token
  end

  private

  def set_defaults
    self.role ||= 'member'
  end

  def check_recipient
    if recipient_user_id.blank? && email.blank?
      errors.add(:email, "cannot be blank")
    end
  end

  def generate_tokens
    generate_token('token')
  end
end
