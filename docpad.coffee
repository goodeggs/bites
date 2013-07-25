require 'sugar'

module.exports =
  env: 'static'

  templateData:
    site:
      title: 'Bytes'
      author: 'Good Eggs'
      url: 'http://goodeggs.github.io/bytes'

      googleAnalytics:
        id: 'UA-26193287-5'

  collections:
    posts: (database) ->
      database.findAllLive({post: true}, [date: -1])

  plugins:
    datefromfilename:
      removeDate: true
      dateRegExp: /\b(\d{4})-(\d{2})-(\d{2})-/
    cleanurls:
      trailingSlashes: true
    rss:
      collection: 'posts'
      url: '/rss'