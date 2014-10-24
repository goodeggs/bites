{raw, img, h3, div, span, section} = require 'teacup'
{postsIndex, nest} = require '../partials/helpers'
base = require './base'

author = ({name, bio, photoURL}) ->
  div '.coauthor', ->
    div '.meta', ->
      img src: photoURL
    div '.content', ->
      raw bio
      div '.author', "- #{name.split(' ')[0]}"

module.exports = nest base, (file) ->
  {collections} = file

  posts = collections.posts.filter (post) ->
    post.author is file.author

  div -> section '.profile', ->
    author
      name: file.author1
      bio: file.bio1
      photoURL: file.photoUrl1
    author
      name: file.author2
      bio: file.bio2
      photoURL: file.photoUrl2

  div '.blog-index', ->
    postsIndex(posts)
