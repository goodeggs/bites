
module.exports = plugin = (opts) ->
  fibrous = require 'fibrous'
  medium = require 'medium-sdk'
  moment = require 'moment'

  publicationName = 'Migration Test Publication 2'

  # Testing accounts
  accessTokens = {
    default: '2cc9e9d735f12d073a181bc5a103a4b344d031e84d7ff0fcb7ce8d2fbb42efe61'
    'Alon Salant': '266e951777c22941cf9f10139fc6a069ee1e7951cc4428836c0af7b9bd8f544ba'
    'Bob Zoller': '2a75676df200947706815eed0ee224360a4002da1cbe9e05148cf9e4050bd1a15'
  }

  # For Good Eggs Product publication
  # All users should be Owner or Editor of the publication
#  accessTokens = {
#    default: '25c8d7a7e1f0da25989ddd4ca3524929630729a9201218f5a24e57aad36224390'
#    'Alon Salant': '21acd3cb27d988bd8e6babea8de1bcf85a014756a21acbe52be6f8ef171e1ec87'
#    'Bob Zoller': '242d5fd8a2da280889ce566fce10788dfe22615e7abb48e9b0faecdf970c58cac'
#    'Max Edmands': '20589cdb25212825dc1a2407f13f7441c840f51cbe14f8351ff7a81ac07f48c76'
#    'Michael Kebbekus': '265c6490ccfc14b23c5463636d82ba8e9555b43abf9a2f3dba5fe9d0369fb3c63'
#  }

  console.log "Running metalsmith-medium with opts", opts

  findPublication = fibrous (client, user, publicationName) ->
    publications = client.sync.getPublicationsForUser userId: user.id
    publication = publications.find (publication) ->
      publication.name is publicationName

    if publication?
      console.log "Publishing to '#{publicationName}' for #{user.name} (#{user.username})"
    else
      throw new Error("Publication '#{publicationName}' not found for #{user.name} (#{user.username})")

    return publication

  (files, metalsmith, done) ->
    # metalsmith seems to check the arity of the above function and it needs to have 3 arguments to be run async
    fibrous.run ->
      return unless opts.enabled

      posts = for path, file of files
        continue unless file.contentsWithoutLayout?
        continue unless ('posts' in file.collection or 'news' in file.collection or 'opensource' in file.collection)

        tags = file.tags or []
        tags.push 'Engineering' unless 'Engineering' in tags

        # Add absolute URLs for images hosted on bites so Medium will import
        content = file.contentsWithoutLayout.toString('utf-8')
        content = content.replace(new RegExp('<a href="/posts/', 'g'), '<a href="http://bites.goodeggs.com/posts/')
        content = content.replace(new RegExp('<img .*?src="/images/', 'g'), '<img src="http://bites.goodeggs.com/images/')

        # If author is not know, add attribution to end of post
        if !accessTokens[file.author]?
          content = """
#{content}
<p>
<i>Originally posted by #{file.author} on #{moment(file.date).format('MMM D, Y')}.</i>
</p>
"""

        content = """
#{content}
<hr>
<i><a href="https://www.goodeggs.com">Good Eggs</a> is the best online groceries for home delivery in the San Francisco Bay Area.
If you are inspired by our mission is to grow and sustain local food systems worldwide,
<a href="http://careers.goodeggs.com">find out how you can help</a>.</i>
"""

        {
          title: file.title
          tags: tags
          path: file.path
          content: content
          date: file.date
          author: file.author
        }

      # Publish oldest to most recent so they show up in the publication in that order
      posts = posts.sort (a, b) -> a.date - b.date

      console.log "Publishing #{posts.length} posts from #{posts[0].date} to #{posts[posts.length - 1].date}"

      defaultClient = new medium.MediumClient {clientId: 'clientId', clientSecret: 'clientSecret'}
      defaultClient.setAccessToken accessTokens['default']
      defaultUser = defaultClient.sync.getUser()
      publication = findPublication.sync defaultClient, defaultUser, publicationName

      for post in posts
        if accessTokens[post.author]?
          client = new medium.MediumClient {clientId: 'clientId', clientSecret: 'clientSecret'}
          client.setAccessToken accessTokens[post.author]
          user = client.sync.getUser()
          console.log "Publishing as #{user.name} (#{user.username})"
        else
          client = defaultClient

        data =
          publicationId: publication.id
          title: post.title
          tags: post.tags
          canonincalUrl: "http://bites.goodeggs.com#{post.path}"
          content: "<h1>#{post.title}</h1>#{post.content}"
          contentFormat: medium.PostContentFormat.HTML
          publishedAt: post.date.toISOString()
          publishStatus: medium.PostPublishStatus.PUBLIC
          notifyFollowers: false

        debugData = {}
        for key, value of data
          if key is 'content'
            debugData[key] = "#{value.substring(0, 1000)}...#{value.substring(value.length - 100)}"
          else
            debugData[key] = value

        if opts.publish
          console.log "Publishing", debugData
          try
            client.sync.createPostInPublication data
          catch e
            # Retry one time due to occasional "socket hangup" errors
            console.error 'Error publishing. Retrying...', e
            try
              client.sync.createPostInPublication data
            catch e
              console.error 'Error publishing', e
        else
          console.log "Not Publishing", debugData

    , done

