{raw, img, h3, div, span, section} = require 'teacup'
{postsIndex, nest} = require '../partials/helpers'
base = require './base'

module.exports = nest base, (file) ->
  {collections, author} = file

  posts = collections.posts.filter (file) ->
    file.author is author

  div -> section '.profile', ->
    div '.meta', ->
      img src: file.photoUrl
    div '.content', ->
      raw file.contents
      div '.author', "- #{author.split(' ')[0]}"

  div '.blog-index', ->
    postsIndex(posts)
