require 'sugar'
{renderable, text, raw, div, p, h1, header, footer, a, article, footer, time} = require 'teacup'

excerptSplitter = /<!--\s*more\s*-->/i

module.exports = helpers =

  hasExcerpt: (content) ->
    excerptSplitter.test content

  excerpt: (content) ->
    return unless content?
    [above, below] = content.split excerptSplitter
    if below? then above else content

  date: (document, {format}={}) ->
    format ?= '{Month} {ord}, {year}'
    date = document.date
    return unless date
    formatted = date.format format

    time datetime: date.utc(true).toISOString(), formatted

  postsIndex: renderable (docs) ->
    for doc in docs
      article ->
        unless doc.noHeader
          header ->
            h1 '.entry-title', ->
              a {href: doc.url}, doc.title
            p '.meta', ->
              a href: "/authors/#{doc.author.underscore()}/", doc.author
              text ' on '
              helpers.date doc
        content = doc.contentRenderedWithoutLayouts
        div '.entry-content', ->
          raw helpers.excerpt content
        if helpers.hasExcerpt content
          footer ->
            a rel: 'full-article', href: doc.url, 'Continue…'

  paginate: renderable (page) ->
    div '.pagination', ->
      if page.hasNextPage()
        a '.prev', href: page.getNextPage(), '← Older'
      # a {href: '/archives/'}, 'Archives'
      if page.hasPrevPage()
        a '.next', href: page.getPrevPage(), '→ Newer'