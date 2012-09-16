class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :answer

  validates :user_id,   :presence => true
  validates :answer_id, :presence => true
  validates :value,     :presence => true, :inclusion => { :in => [-1, 1] }

  after_save :prevent_duplicate_votes
  after_save :cache_points_on_answer

  private

  def prevent_duplicate_votes
    Vote.where(:user_id => user_id, :answer_id => answer_id).each do |v|
      if v != self
        v.destroy
      end
    end
  end

  def cache_points_on_answer
    answer.update_points_cache
  end
end
