assets = require 'metalsmith-assets'
collections = require 'metalsmith-collections'
feed = require 'metalsmith-feed'
jekyllDates = require 'metalsmith-jekyll-dates'
markdown = require 'metalsmith-markdown'
metallic = require 'metalsmith-metallic'
metalsmith = require 'metalsmith'
more = require 'metalsmith-more'
paginate = require 'metalsmith-collections-paginate'
teacup = require 'metalsmith-teacup'
permalinks = require 'metalsmith-permalinks'
medium = require './metalsmith-medium'
{dirname, normalize} = require 'path'

dateThenTitle = (a, b) ->
  if a.date == b.date
    if a.title > b.title then 1 else -1
  else
    if a.date < b.date then 1 else -1

module.exports = (done) ->
  metalsmith __dirname
  .source 'src/documents'
  .metadata
    site:
      title: 'Bites from Good Eggs'
      author: 'Good Eggs'
      url: 'http://bites.goodeggs.com/'
      googleAnalytics:
        id: 'UA-26193287-5'

  .use jekyllDates()
  .use metallic()
  .use markdown()
  .use more()

  .use (files, metalsmith, done) ->
    # Snapshot contents before rendering
    for name, file of files
      file.contentsWithoutLayout = file.contents
    done()

  .use collections
    posts:
      pattern: 'posts/*'
      sortBy: 'date'
      reverse: true
    openSource:
      pattern: 'open_source/*'
      sortBy: dateThenTitle
    authors:
      pattern: 'authors/*'
    news:
      sortBy: 'date'
      reverse: true

  .use paginate
    posts:
      perPage: 10
      first: 'index.html'
      path: 'posts/:num/index.html'
      template: 'posts'

    openSource:
      perPage: 20
      first: 'open_source/index.html'
      path: 'open_source/:num/index.html'
      template: 'open_source'

    news:
      perPage: 20
      first: 'news/index.html'
      path: 'news/:num/index.html'
      template: 'news'

  # Generate file paths
  .use (files, metalsmith, done) ->
    for filename, file of files
      file.dirname = dirname filename
    done()

  .use permalinks
    relative: false
    pattern: ':dirname/:slug'

  ## Absolute paths with trailing slashes
  .use (files, metalsmith, done) ->
    for filename, file of files
      file.path = normalize "/#{file.path or ''}/"
    done()

  .use feed
    collection: 'posts'
    destination: 'rss'

  # Map layouts to templates
  .use (files, metalsmith, done) ->
    for filename, file of files
      continue unless file.layout
      file.template = file.layout
    done()
  .use teacup directory: 'src/layouts'

  .use assets
    source: 'src/files'
    destination: '.'

  .use medium
    enabled: process.env.PUBLISH_TO_MEDIUM is 'true'
    accessToken: '2cc9e9d735f12d073a181bc5a103a4b344d031e84d7ff0fcb7ce8d2fbb42efe61'
    publicationName: 'Migration Test Publication'

  .destination 'build'
  .clean false # handled by gulp
  .build done
