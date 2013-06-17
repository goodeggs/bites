---
layout: default
isPaged: true
pagedCollection: posts
pageSize: 10
---
{a, article, footer, div, h1, header, p, raw, text} = require 'teacup'
{excerpt, hasExcerpt, date} = require '../partials/helpers'

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

  div '.blog-index', ->
    for post in page.docs
      article ->
        unless post.noHeader
          header ->
            h1 '.entry-title', ->
              a {href: post.url}, post.title
            p '.meta', ->
              text post.author
              text ' on '
              date post
        content = post.contentRenderedWithoutLayouts
        div '.entry-content', ->
          raw excerpt content
        if hasExcerpt content
          footer ->
            a rel: 'full-article', href: post.url, 'Continue…'

    div '.pagination', ->
      if page.hasNextPage()
        a '.prev', href: page.getNextPage(), '← Older'
      # a {href: '/archives/'}, 'Archives'
      if page.hasPrevPage()
        a '.next', href: page.getPrevPage(), '→ Newer'
