class AddWelcomeMessageToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :welcome_message, :text
  end
end
