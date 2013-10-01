---
layout: default
---
{raw, img, h3, div} = require 'teacup'
{postsIndex} = require '../partials/helpers'

module.exports = (docpad) ->
  {document, content} = docpad

  page = {}
  page.docs = docpad.getCollection('posts')
    .findAllLive(author: document.author,[{date:-1}])
    .map((doc) -> doc.toJSON())

  div '.intro', ->
    img src: "#{document.photoUrl}/convert?w=150&h=150&fit=crop&align=faces&cache=true"
    h3 document.author
    raw content

  div '.blog-index', ->
    postsIndex(page.docs)