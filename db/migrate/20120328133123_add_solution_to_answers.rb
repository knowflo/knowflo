class AddSolutionToAnswers < ActiveRecord::Migration
  def change
    add_column :answers, :solution, :boolean
  end
end
