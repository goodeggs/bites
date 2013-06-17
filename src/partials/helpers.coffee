require 'sugar'
{time} = require 'teacup'

excerptSplitter = /<!--\s*more\s*-->/i

module.exports = 

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


