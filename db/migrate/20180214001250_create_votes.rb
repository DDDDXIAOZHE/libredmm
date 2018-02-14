class CreateVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :votes do |t|
      t.references :user, foreign_key: true
      t.references :movie, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
