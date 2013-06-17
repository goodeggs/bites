require 'sugar'

module.exports =
  env: 'static'

  templateData:
    site:
      title: 'Bytes'
      author: 'Good Eggs'
      url: 'http://goodeggs.github.io/bytes'

      # googleAnalytics:
      #   id: '?'

  collections:
    posts: (database) ->
      database.findAllLive({post: true}, [date: -1])

  plugins:
    datefromfilename:
      removeDate: true
    cleanurls:
      trailingSlashes: true