---
layout: default
---
{raw, img, h3, div, span, section} = require 'teacup'
{postsIndex} = require '../partials/helpers'

module.exports = (docpad) ->
  {document, content} = docpad

  page = {}
  page.docs = docpad.getCollection('posts')
    .findAllLive(author: document.author,[{date:-1}])
    .map((doc) -> doc.toJSON())

  div -> section '.profile', ->
    div '.meta', ->
      img src: "#{document.photoUrl}/convert?w=150&h=150&fit=crop&align=faces&cache=true"
    div '.content', ->
      raw content
      div '.author', "- #{document.author.split(' ')[0]}"

  div '.blog-index', ->
    postsIndex(page.docs)