class AddNotificationsToMemberships < ActiveRecord::Migration
  def change
    add_column :memberships, :notifications_enabled, :boolean, default: true
  end
end
