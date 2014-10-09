require 'sugar'
{renderable, render, text, raw, div, p, h1, header, footer, a, article, footer, time} = require 'teacup'

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

  postsIndex: renderable (files) ->
    for file in files
      article ->
        unless file.noHeader
          header ->
            h1 '.entry-title', ->
              a {href: file.path}, file.title
            p '.meta', ->
              a href: "/authors/#{file.author.underscore()}/", file.author
              text ' on '
              helpers.date file
        content = file.contentContentsWithoutLayout
        div '.entry-content', ->
          raw helpers.excerpt content
        if helpers.hasExcerpt content
          footer ->
            a rel: 'full-article', href: file.path, 'Continue…'

  paginate: renderable (file) ->
    div '.pagination', ->
      if file.paginate.next
        a '.prev', href: file.paginate.next.path, '← Older'
      if file.paginate.previous
        a '.next', href: file.paginate.previous.path, '→ Newer'

  # Nests layouts
  nest: (parent, layout) ->
    renderable (file) ->
      file = Object.create(file)
      file.contents = render layout, file
      parent file
