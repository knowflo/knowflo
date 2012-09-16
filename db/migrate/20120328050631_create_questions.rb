class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer :user_id
      t.string :subject
      t.text :body
      t.string :url
      t.integer :group_id

      t.timestamps
    end
  end
end
