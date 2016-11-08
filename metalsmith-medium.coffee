fibrous = require 'fibrous'
medium = require 'medium-sdk'


module.exports = plugin = (opts) ->
  console.log "Running metalsmith-medium with opts", opts

  (files, metalsmith, done) ->
    # metalsmith seems to check the arity of the above function and it needs to have 3 arguments to be run async
    fibrous.run ->
      return unless opts.enabled

      client = new medium.MediumClient {clientId: 'clientId', clientSecret: 'clientSecret'}
      client.setAccessToken opts.accessToken

      user = client.sync.getUser()
      console.log "Looking for publication '#{opts.publicationName}' for user #{user.username}"
      publications = client.sync.getPublicationsForUser userId: user.id
      publication = publications.find (publication) ->
        publication.name = opts.publicationName

      throw new Error("Publication '#{opts.publicationName}' not found for user #{user.username}") unless publication?

      console.log "Found publication '#{publication.name}'"

      for path, file of files
        continue unless path is 'posts/self-updating-go-binaries-with-go-selfupdate/index.html'
        continue unless file.contentsWithoutLayout?
        continue unless ('posts' in file.collection or 'news' in file.collection or 'opensource' in file.collection)

        tags = file.tags or []
        tags.push 'Engineering' unless 'Engineering' in tags

        console.log "Publishing", {
          path: path
          title: file.title
          author: file.author
          date: file.date
          tags: tags
          collection: file.collection
          contentsWithoutLayout: file.contentsWithoutLayout.toString('utf-8').substring(0,200)
      #          keys: Object.keys(file)
        }

        # TODO:
        # X. publishedAt - need to patch medium-sdk (https://github.com/Medium/medium-api-docs/issues/6)
        # 2. Handle images hosted on bites.goodeggs.com
        # 3. Attribute authors
        # 4. "Originally posted on ..."
        # 5. Standard about Good Eggs & hiring blurb
        # X. Add Post title to content as H1
        data =
          publicationId: publication.id
          title: file.title
          tags: tags
          canonincalUrl: "http://bites.goodeggs.com#{file.path}"
          content: file.contentsWithoutLayout.toString('utf-8')
          contentFormat: medium.PostContentFormat.HTML
          publishedAt: file.date.toISOString()
          publishStatus: medium.PostPublishStatus.PUBLIC
          notifyFollowers: false

        client.sync.createPostInPublication data

    , done
