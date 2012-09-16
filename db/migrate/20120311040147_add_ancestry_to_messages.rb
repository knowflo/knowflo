class AddAncestryToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :ancestry, :string
    add_index :messages, :ancestry
  end
end
