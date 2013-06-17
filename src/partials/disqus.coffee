{div, script} = require 'teacup'

module.exports = ({shortname, url}) ->
  div '#disqus_thread'
  script [
    "window.disqus_shortname = '#{shortname}'"
    "window.disqus_url = '#{url}'" if url
  ].join '; '
  script async: true, src: "//#{shortname}.disqus.com/embed.js", ''
