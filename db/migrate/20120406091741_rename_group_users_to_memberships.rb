class RenameGroupUsersToMemberships < ActiveRecord::Migration
  def change
    rename_table :group_users, :memberships
    add_column :memberships, :invitation_email, :string
    add_column :memberships, :token, :string
    add_column :memberships, :invited_by_user_id, :integer
  end
end
