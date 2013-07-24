{
  doctype, html, head, title, meta, link,
  body, header, footer, h1, br, div, p, a, raw,
  script, text
} = require 'teacup'

module.exports = ({site, document, content}) ->
  doctype 5
  throw new Error() unless {}.constructor is Object
  html '.no-js', lang: 'en', ->
    head ->
      meta charset: 'utf-8'
      title document.title or site.title

      if document.author
        meta name: 'author', content: document.author
      if document.description
        meta name: 'description', content: document.description
      if document.keywords
        meta name: 'keywords', content: document.keywords
      if document.canonical
        link rel: 'canonical', href: document.canonical

      meta name: 'viewport', content: 'width=device-width, initial-scale=1'

      link rel: 'icon', type: 'image/png', href: '/favicon.png'
      link rel: 'stylesheet', href: '/styles/main.css'
      link rel: 'alternate', title: 'RSS', type: 'application/rss+xml', href: '/rss.xml'

      if site.googleAnalytics?.id
        script """
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{site.googleAnalytics.id}']);
          _gaq.push(['_trackPageview']);

          (function() {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
          })();
        """

    body ->
      header ->
        h1 ->
          a href: '/', 'Bytes'

      div '#main', ->
        div '#content', ->
          raw content

      footer ->
        p '©2013 Good Eggs, Inc'
