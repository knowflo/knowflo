class User < ActiveRecord::Base
  include TokenGenerator
  has_secure_password
  acts_as_url :name

  attr_protected :admin

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :votes

  has_many :followings, dependent: :destroy
  has_many :following_questions, through: :followings, source: :question

  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships

  validates :first_name, :presence => true
  validates :last_name,  :presence => true
  validates :email,      :presence => true, :uniqueness => true, :email_format => true
  validates :password,   :presence => { :on => :create }, :length => { :minimum => 6 }, :if => :password_changed?
  validates :url,        :presence => true, :uniqueness => true

  with_options :if => :using_omniauth? do |user|
    user.validates :auth_uid,      :presence   => true, :uniqueness => { :scope => :auth_provider }
    user.validates :auth_provider, :presence   => true
  end

  before_validation :generate_tokens, :on => :create

  accepts_nested_attributes_for :memberships

  def self.authenticate(email, password)
    if user = find_by_email(email)
      user.authenticate(password)
    else
      false
    end
  end

  def self.create_with_omniauth!(auth_data)
    create! do |user|
      user_info = auth_data['info'] || {}
      user.auth_provider = auth_data['provider']
      user.auth_uid = auth_data['uid']
      user.first_name = user_info['first_name']
      user.last_name = user_info['last_name']
      user.email = user_info['email']
      user.avatar_url = user_info['image']
      # user.nickname = user_info['nickname']
      # user.remote_avatar_url = (user_info['image'] || '').gsub(/type\=square/, 'type=large')
      # user.facebook_url = (user_info['urls'] || {})['Facebook']
      # user.facebook_location = user_info['location']
      user.generate_password
    end
  end

  def generate_password
    self.password = SecureRandom.hex(8)
  end

  def password_changed?
    new_record? || password_digest_changed?
  end

  def using_omniauth?
    auth_uid.present? || auth_provider.present?
  end

  def avatar_url(size = 80)
    read_attribute(:avatar_url) || (email.present? ? Gravatar.for(email.strip, size) : nil)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def to_s
    email
  end

  def to_param
    url
  end

  private

  def generate_tokens
    generate_token('remember_token')
  end
end
