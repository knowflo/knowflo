class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.integer :parent_id
      t.string :subject
      t.text :body
      t.timestamps
    end
  end
end
