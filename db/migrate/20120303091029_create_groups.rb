class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :privacy
      t.string :url
      t.timestamps
    end

    create_table :group_users do |t|
      t.integer :user_id
      t.integer :group_id
      t.string :role
      t.timestamps
    end

    add_index :groups, :url
    add_index :group_users, [:user_id, :group_id]
  end
end
