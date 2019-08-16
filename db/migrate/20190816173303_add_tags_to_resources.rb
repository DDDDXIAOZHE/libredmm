# frozen_string_literal: true

class AddTagsToResources < ActiveRecord::Migration[5.2]
  def change
    add_column :resources, :tags, :string, array: true, default: []
  end
end
