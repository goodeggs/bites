---
title: News
layout: default
collection: news
---
{a, article, footer, div, h1, header, p, raw, text} = require 'teacup'
{postsIndex} = require '../partials/helpers'

module.exports = (docpad) ->
  # TODO: extract this
  document = docpad.document
  page = {}
  page.docs = docpad.getCollection(document.collection)
    .map((doc) -> doc.toJSON())

  div '.intro', -> raw """
Selected posts that provide a window into what's going on behind the scenes at Good Eggs.
"""

  div '.blog-index', ->
    postsIndex(page.docs)

