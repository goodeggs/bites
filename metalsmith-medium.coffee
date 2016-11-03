module.exports = plugin = ->
  (files, metalsmith, done) ->
    for file in files
      console.log file
    done()