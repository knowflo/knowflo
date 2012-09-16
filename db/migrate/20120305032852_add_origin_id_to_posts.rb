class AddOriginIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :origin_id, :integer
  end
end
