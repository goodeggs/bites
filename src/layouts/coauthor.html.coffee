---
layout: default
---
{raw, img, h3, div, span, section} = require 'teacup'
{postsIndex} = require '../partials/helpers'

author = ({name, bio, photoURL}) ->
  div '.coauthor', ->
    div '.meta', ->
      img src: photoURL
    div '.content', ->
      raw bio
      div '.author', "- #{name.split(' ')[0]}"

module.exports = (docpad) ->
  {document, content} = docpad

  page = {}
  page.docs = docpad.getCollection('posts')
    .findAllLive(author: document.author,[{date:-1}])
    .map((doc) -> doc.toJSON())

  div -> section '.profile', ->
    author
      name: document.author1
      bio: document.bio1
      photoURL: document.photoUrl1
    author
      name: document.author2
      bio: document.bio2
      photoURL: document.photoUrl2

  div '.blog-index', ->
    postsIndex(page.docs)