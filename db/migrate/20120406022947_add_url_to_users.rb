class AddUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :url, :string
    add_index :users, :url
  end
end
