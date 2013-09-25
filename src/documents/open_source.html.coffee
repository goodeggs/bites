---
layout: default
collection: openSource
---
{a, article, section, footer, div, h1, header, p, raw, text} = require 'teacup'
{postsIndex} = require '../partials/helpers'

module.exports = (docpad) ->
  # TODO: extract this
  document = docpad.document
  page = {}
  page.docs = docpad.getCollection(document.collection)
    .map((doc) -> doc.toJSON())

  div '.intro', -> raw """
We're psyched to be active members of a community that is building great tools for JavaScript developers
across the stack. A couple projects are featured below and you can check out all of our open source work at
<a href="https://github.com/goodeggs">github.com/goodeggs</a>.
"""

  div '.blog-index', ->
    postsIndex(page.docs)

