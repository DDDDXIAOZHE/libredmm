class ChangeReleaseDateToBeDateInMovies < ActiveRecord::Migration[5.1]
  def up
    rename_column :movies, :release_date, :release_date_str
    add_column :movies, :release_date, :date
    Movie.find_each do |movie|
      movie.update!(release_date: movie.release_date_str)
      puts "#{movie.code}: #{movie.release_date_str} -> #{movie.release_date}"
    end
    remove_column :movies, :release_date_str
  end

  def down
    rename_column :movies, :release_date, :release_date_dt
    add_column :movies, :release_date, :string
    Movie.find_each do |movie|
      movie.update!(release_date: movie.release_date_dt.to_s(:db))
      puts "#{movie.code}: #{movie.release_date_dt} -> #{movie.release_date}"
    end
    remove_column :movies, :release_date_dt
  end
end
