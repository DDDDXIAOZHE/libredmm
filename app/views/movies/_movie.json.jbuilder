json.extract! movie, :id, :actresses, :actress_types, :categories, :code, :cover_image, :description, :directors, :genres, :label, :maker, :movie_length, :page, :release_date, :sample_images, :series, :tags, :thumbnail_image, :title, :created_at, :updated_at
json.url movie_url(movie, format: :json)
