
module.exports = plugin = (opts) ->
  console.log "Running metalsmith-medium with opts", opts

  (files, metalsmith, done) ->
    return done() unless opts.enabled

    for path, file of files
      continue unless file.contentsWithoutLayout?
      continue unless ('posts' in file.collection or 'news' in file.collection or 'opensource' in file.collection)

      tags = file.tags or []
      tags.push 'Engineering' unless 'Engineering' in tags

      console.log {
        path: path
        title: file.title
        author: file.author
        date: file.date
        tags: tags
        collection: file.collection
        contentsWithoutLayout: file.contentsWithoutLayout.toString('utf-8').substring(0,200)
#        keys: Object.keys(file)
      }
    done()