---
layout: default
isPaged: true
pagedCollection: posts
pageSize: 10
---
{raw, div, section, raw} = require 'teacup'
{postsIndex, paginate} = require '../partials/helpers'

module.exports = (docpad) ->
  # TODO: extract this
  document = docpad.document
  documentModel = docpad.getDocument()

  # TODO: and this
  page = document.page
  page.docs = docpad.getCollection(document.pagedCollection)
    .slice(page.startIdx, page.endIdx)
    .map((doc) -> doc.toJSON())
  page.hasNextPage = -> documentModel.hasNextPage()
  page.hasPrevPage = -> documentModel.hasPrevPage()
  page.getNextPage = -> documentModel.getNextPage()
  page.getPrevPage = -> documentModel.getPrevPage()

  div '.intro', -> raw """
Bites is the developer site from the team building the platform for local food shopping and distribution at
<a href="http://www.goodeggs.com">goodeggs.com</a>. Here we share our experiences building applications with
full-stack JavaScript, our open source projects and insight into a developer's life at Good Eggs.
"""

  div '.blog-index', ->
    postsIndex(page.docs)
    paginate(page)
