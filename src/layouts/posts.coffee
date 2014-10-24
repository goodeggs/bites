{raw, div, section} = require 'teacup'
{postsIndex, paginate, nest} = require '../partials/helpers'
base = require './base'

module.exports = nest base, (file) ->

  div -> section -> raw """
Bites is the developer site from the team building the platform for local food shopping and distribution at
<a href="https://www.goodeggs.com">goodeggs.com</a>. Here we share our experiences building applications with
full-stack JavaScript, our open source projects and insight into a developer's life at Good Eggs.
"""

  div '.blog-index', ->
    postsIndex(file.paginate.files)
    paginate(file)
