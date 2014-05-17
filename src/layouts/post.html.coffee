---
layout: default
---
url = require 'url'
{a, article, div, footer, h1, header, p, script, style, tag, text, raw, img} = require 'teacup'
{date} = require '../partials/helpers'
disqus = require '../partials/disqus'

module.exports = ({document, content}) ->

  author = @getAuthor()

  div =>
    article '.post', role: 'article', =>
      if document.style
        tag 'style', scoped: true, =>
          raw document.style

      unless document.noHeader
        header =>
          img '.author', src: author.photoUrl, alt: author.author
          h1 '.entry-title', document.title
          p '.meta', =>
            a href: "/authors/#{document.author.underscore()}/", document.author
            text ' on '
            date document
          if document.canonical?
            p '.meta.canonical', =>
              text
              a href: document.canonical, target: '_blank', =>
                text 'Crossposted from '
                text url.parse(document.canonical, false, true).host

      div '.entry-content', =>
        raw content

      footer =>
        p '.meta', =>
          # TODO: extract into plugin, assumes sorted newest first
          posts = @getCollection('posts')
          index = posts.indexOf(@getDocument())
          return if index is -1 # Not a post, e.g. open source pages
          previousDocument = null
          nextDocument = null
          if index < posts.length - 1
            previousDocument = posts.at(index + 1).toJSON()
          if index > 0
            nextDocument = posts.at(index - 1).toJSON()
          if previousDocument
            a '.basic-alignment.left', href: previousDocument.url, =>
              raw '&laquo; '
              text previousDocument.title

          if nextDocument
            a '.basic-alignment.right', href: nextDocument.url, =>
              text nextDocument.title
              raw ' &raquo;'

        if document.disqus
          disqus
            shortname: document.disqus.shortname
            url: document.disqus.url or document.canonical or document.url
