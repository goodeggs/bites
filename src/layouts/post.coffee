url = require 'url'
{a, article, div, footer, h1, header, p, script, style, tag, text, raw, img} = require 'teacup'
{date, nest} = require '../partials/helpers'
disqus = require '../partials/disqus'
base = require './base'

module.exports = nest base, (file) ->
  {site, collections} = file

  author = collections.authors.filter(({author}) -> file.author == author)[0]

  div =>
    article '.post', role: 'article', =>
      if file.style
        tag 'style', scoped: true, =>
          raw file.style

      unless file.noHeader
        header =>
          img '.author', src: author.photoUrl, alt: author.author
          h1 '.entry-title', file.title
          p '.meta', =>
            a '.entry-author-name', href: "/authors/#{file.author.underscore()}/", file.author
            text ' on '
            date file
          if file.canonical?
            p '.meta.canonical', =>
              text
              a href: file.canonical, target: '_blank', =>
                text 'Crossposted from '
                text url.parse(file.canonical, false, true).host

      div '.entry-content', =>
        raw file.contents

      footer =>
        p '.meta', =>
          if next = file.next
            a '.basic-alignment.left', href: next.path, ->
              raw '&laquo; '
              text next.title

          if previous = file.previous
            a '.basic-alignment.right', href: previous.path, ->
              text previous.title
              raw ' &raquo;'

        if file.disqus
          disqus
            shortname: file.disqus.shortname
            url: file.disqus.url or file.canonical or file.url
