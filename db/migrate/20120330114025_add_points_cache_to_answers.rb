class AddPointsCacheToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :points_cache, :integer
  end
end
