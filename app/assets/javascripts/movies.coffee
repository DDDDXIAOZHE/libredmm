# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("a.link_to_open_all").click (e) ->
    e.preventDefault()
    urls = $(this).data("urls")
    urls.map (url) ->
      window.open(url, "_blank")