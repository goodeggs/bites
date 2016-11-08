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

      posts = for path, file of files
        continue unless file.contentsWithoutLayout?
        continue unless ('posts' in file.collection or 'news' in file.collection or 'opensource' in file.collection)

        tags = file.tags or []
        tags.push 'Engineering' unless 'Engineering' in tags

        # Add absolute URLs for images hosted on bites so Medium will import
        content = file.contentsWithoutLayout.toString('utf-8')
        content = content.replace(new RegExp('<a href="/posts/', 'g'), '<a href="http://bites.goodeggs.com/posts/')
        content = content.replace(new RegExp('<img src="/images/', 'g'), '<img src="http://bites.goodeggs.com/images/')

        {
          title: file.title
          tags: tags
          path: file.path
          content: content
          date: file.date
        }

      # Publish oldest to most recent so they show up in the publication in that order
      posts = posts.sort (a, b) -> a.date - b.date

      console.log "Publishing #{posts.length} posts from #{posts[0].date} to #{posts[posts.length - 1].date}"

      # TODO:
      # X. publishedAt - need to patch medium-sdk (https://github.com/Medium/medium-api-docs/issues/6)
      # X. Handle images hosted on bites.goodeggs.com
      # 3. Attribute authors
      # N. "Originally posted on ..."
      # 5. Standard about Good Eggs & hiring blurb
      # X. Add Post title to content as H1
      for post in posts
        data =
          publicationId: publication.id
          title: post.title
          tags: post.tags
          canonincalUrl: "http://bites.goodeggs.com#{post.path}"
          content: "<h1>#{post.title}</h1>#{post.content}"
          contentFormat: medium.PostContentFormat.HTML
          publishedAt: post.date.toISOString()
          publishStatus: medium.PostPublishStatus.DRAFT
          notifyFollowers: false

        if opts.publish
          console.log "Publishing", data
          client.sync.createPostInPublication data
        else
          console.log "Not Publishing", data

    , done
