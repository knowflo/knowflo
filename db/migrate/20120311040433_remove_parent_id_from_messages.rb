class RemoveParentIdFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :parent_id
  end
end
