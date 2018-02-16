class CreateResources < ActiveRecord::Migration[5.1]
  def change
    create_table :resources do |t|
      t.references :movie, foreign_key: true
      t.string :download_uri
      t.string :source_uri
      t.string :note

      t.timestamps
    end
  end
end
