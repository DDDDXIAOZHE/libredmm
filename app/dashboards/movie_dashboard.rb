# frozen_string_literal: true

require "administrate/base_dashboard"

class MovieDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    votes: Field::HasMany,
    resources: Field::HasMany,
    obsolete_resources: Field::HasMany.with_options(class_name: "Resource"),
    id: Field::Number,
    actresses: Field::String,
    actress_types: Field::String,
    categories: Field::String,
    code: Field::String,
    cover_image: Field::String,
    description: Field::String,
    directors: Field::String,
    genres: Field::String,
    label: Field::String,
    maker: Field::String,
    movie_length: Field::String,
    page: Field::String,
    sample_images: Field::String,
    series: Field::String,
    tags: Field::String,
    thumbnail_image: Field::String,
    title: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    release_date: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    code
    title
    resources
    votes
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    votes
    resources
    obsolete_resources
    id
    actresses
    actress_types
    categories
    code
    cover_image
    description
    directors
    genres
    label
    maker
    movie_length
    page
    sample_images
    series
    tags
    thumbnail_image
    title
    created_at
    updated_at
    release_date
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    actresses
    actress_types
    categories
    code
    cover_image
    description
    directors
    genres
    label
    maker
    movie_length
    page
    sample_images
    series
    tags
    thumbnail_image
    title
    release_date
  ].freeze

  # Overwrite this method to customize how movies are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(movie)
  #   "Movie ##{movie.id}"
  # end
end
