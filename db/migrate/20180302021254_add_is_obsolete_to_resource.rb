class AddIsObsoleteToResource < ActiveRecord::Migration[5.1]
  def change
    add_column :resources, :is_obsolete, :boolean, default: false
  end
end
