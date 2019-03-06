class RemoveNoteFromResources < ActiveRecord::Migration[5.2]
  def change
    remove_column :resources, :note, :string
  end
end
