{raw, div, section} = require 'teacup'
{postsIndex, nest} = require '../partials/helpers'
base = require './base'

module.exports = nest base, (file) ->
  file.title = 'News'

  div -> section -> raw """
A window into what's going on behind the scenes at Good Eggs.
"""

  div '.blog-index', ->
    postsIndex(file.paginate.files)

