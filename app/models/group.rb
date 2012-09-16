class Group < ActiveRecord::Base
  PRIVACY_OPTIONS = ['private', 'public']
  FORBIDDEN_SLUGS  = ['www', 'new', 'knowflo', 'knowflow']

  acts_as_url :name

  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  has_many :questions, :dependent => :destroy
  has_many :answers, :through => :questions

  validates :name,    :presence => true
  validates :privacy, :presence => true, :inclusion => { :in => PRIVACY_OPTIONS }
  validates :url,     :presence => true, :uniqueness => true, :exclusion => { :in => FORBIDDEN_SLUGS }

  before_validation :set_defaults, :on => :create

  PRIVACY_OPTIONS.each do |status|
    define_method("#{status}?") do
      privacy == status
    end

    scope "#{status}_groups".to_sym, where('privacy=?', status)
  end

  def to_param
    url
  end

  def to_s
    "Group ##{id}: #{name}"
  end

  def user_role(user)
    memberships.find_by_user_id(user.id).try(:role)
  end

  def self.visible(user)
    (Group.where(:privacy => 'public') + user.groups).uniq
  end

  def visible_to(user)
    public? || user.groups.include?(self)
  rescue
    false
  end

  private

  def set_defaults
    self.privacy ||= 'public'
  end
end
