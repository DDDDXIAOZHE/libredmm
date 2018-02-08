class CreateMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movies do |t|
      t.string :actresses, array: true
      t.string :actress_types, array: true
      t.string :categories, array: true
      t.string :code
      t.string :cover_image
      t.string :description
      t.string :directors, array: true
      t.string :genres, array: true
      t.string :label
      t.string :maker
      t.string :movie_length
      t.string :page
      t.string :release_date
      t.string :sample_images, array: true
      t.string :series
      t.string :tags, array: true
      t.string :thumbnail_image
      t.string :title

      t.timestamps
    end
  end
end
