class AddLogoUrlToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :logo_url, :string
  end
end
