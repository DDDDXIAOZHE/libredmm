class AddIndexToMovies < ActiveRecord::Migration[6.0]
  def change
    add_index :movies, :code
  end
end
