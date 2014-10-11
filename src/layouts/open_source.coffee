{raw, div, section} = require 'teacup'
{postsIndex, nest} = require '../partials/helpers'
base = require './base'

module.exports = nest base, (file) ->
  file.title = 'Open Source'

  div -> section -> raw """
We're psyched to be active members of a community that is building great tools for JavaScript developers
across the stack. A couple projects are featured below and you can check out all of our open source work at
<a href="https://github.com/goodeggs">github.com/goodeggs</a>.
"""

  div '.blog-index', ->
    postsIndex(file.paginate.files)

