---
title: News
layout: default
collection: news
---
{raw, div, section} = require 'teacup'
{postsIndex} = require '../partials/helpers'

module.exports = (docpad) ->
  # TODO: extract this
  document = docpad.document
  page = {}
  page.docs = docpad.getCollection(document.collection)
    .map((doc) -> doc.toJSON())

  div -> section -> raw """
Selected posts that provide a window into what's going on behind the scenes at Good Eggs.
"""

  div '.blog-index', ->
    postsIndex(page.docs)

