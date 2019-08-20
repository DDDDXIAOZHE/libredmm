# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

admin = User.create!(email: "admin@libredmm.com", password: "password", is_admin: true)
Movie.search!("AVOP-111")
Vote.create!(user: admin, movie: Movie.search!("ABP-123"), status: :up)
Vote.create!(user: admin, movie: Movie.search!("SDDE-222"), status: :down)
Resource.create(movie: Movie.search!("SDDE-222"), download_uri: "http://www.libredmm.com")
