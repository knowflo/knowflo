class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :remember_token
      t.boolean :admin
      t.string :first_name
      t.string :last_name
      t.string :auth_uid
      t.string :auth_provider
      t.string :ip_address

      t.timestamps
    end

    add_index "users", "email"
  end
end
