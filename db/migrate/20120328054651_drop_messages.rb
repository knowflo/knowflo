class DropMessages < ActiveRecord::Migration
  def change
    drop_table :messages
    add_index :questions, :url
  end
end
