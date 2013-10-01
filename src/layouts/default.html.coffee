{
  doctype, html, head, title, meta, link,
  body, header, footer, h1, br, div, p, a, raw, ul, li
  script, text
} = require 'teacup'

module.exports = ({site, document, content}) ->
  doctype 5
  throw new Error() unless {}.constructor is Object
  html '.no-js', lang: 'en', ->
    head ->
      meta charset: 'utf-8'
      title document.title and "#{document.title} | #{site.title}" or site.title

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
      link rel: 'alternate', title: 'RSS', type: 'application/rss+xml', href: '/rss'

      if site.googleAnalytics?.id
        script """
          (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
          (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
          m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
          })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

          ga('create', '#{site.googleAnalytics.id}', 'github.io');
          ga('send', 'pageview');
        """

    body ->
      header ->
        h1 ->
          a href: '/', 'Bites'
        ul '.unstyled.nav', ->
          for section, url of {'Blog': '/', 'Open Source': '/open_source', 'News': '/news'}
            li ->
              a href: url, section

      div '#main', ->
        div '#content', ->
          raw content

      footer ->
        div '.mission', 'Our mission is to grow and sustain local food systems worldwide.'
        p '©2013 Good Eggs, Inc'
