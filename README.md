# Bites
The Good Eggs developer blog.

[![Build Status](http://img.shields.io/travis/goodeggs/bites.svg?style=flat-square)](https://travis-ci.org/goodeggs/bites)

Why blog?
---------

**Notoriety**
Our blog, open source software, and developer events are all opportunities for us
to establish Good Eggs as a _tech company_ in addition to a revolutionary local food company.

**Reinforce the [Manifesto](https://github.com/goodeggs/bites/blob/master/src/documents/posts/2014-02-25-manifesto.html.md#we-believe)**
_We believe_ in the value of exploration and innovation, and the blog is a platform to share what we learn and create.

**Develop Tech Talks for Conferences**
Consolidating ideas into a blog post is most of the legwork for creating a compelling talk for conferences and other events!

**Share information with our team**
As our engineering team keeps getting bigger, it's hard to keep track of all of the cool things we're doing. Do you know about the cool ways the new Driver app is using offline storage? Me neither!

What to blog about?
-------------------
Posts can range from in-depth technical articles to brief posts relating a personal experience about software. Our goal is to share what we're doing here in Good Eggs in all aspects of Engineering. They can be short, long, or anywhere in between. Here are a few ideas:

* design patterns and techniques we're using
* tools, services, and libraries we're using
* open source software we authored
* process (daily standups, retrospectives, etc)
* relate a personal experience (fixing a bug that helped a customer, implementing a feature that saved ops time, etc.)
* a developer event we held
* cool tech you saw/heard/tried/read about/etc.


**Got an Idea?**
[Open an issue](https://github.com/goodeggs/bites/issues/new) with the label `blog post idea` and summarize some of the keypoints that will make the post interesting. You or someone else on the team can write it later.

**Need an Idea?**
Check the [open blog post ideas](https://github.com/goodeggs/bites/issues?labels=blog+post+idea&state=open) that haven't been written yet!

How to write a post?
--------------------

**Intro**
Give the reader a concise overview of what they'll get out of the post. If it's a long post, create a table of contents.

**Pictures**
Relevant pictures make a post a lot easier to digest.

**Code Examples**
Always show some `code` if the post is about coding!

**Links**
Talking about a library, tool, an event you went to, someone else's blog, etc? Try a [hyperlink](http://en.wikipedia.org/wiki/Hyperlink)!

**Summary**
Sum it up. Take a stance. Give an opinion.

How to post a post?
-------------------
Install and fire up the development server

    > npm install
    > grunt dev

Start a new branch

    > git checkout -b <post-slug>

Add a new post to [src/documents/posts](https://github.com/goodeggs/bites/tree/master/src/documents/posts)

    > touch src/documents/posts/YYYY-MM-DD-your-post-slug.html.md

If it's your first post, create your author page in [src/documents/authors](https://github.com/goodeggs/bites/tree/master/src/documents/authors)

Check it out at `http://localhost:8000/your-post-slug` or just `grunt open:preview`.  It'll regenerate when you change the source files.

When it looks right commit and push your post:

    > git add .
    > git commit -m "Yay. I wrote a post."
    > git push

When you're ready to share, make a pull request and send an E-Mail to [eng@goodeggs.com](mailto:eng@goodeggs.com) and ask for feedback.

And then stage and release:

    > grunt stage
    > grunt release

How to promote a post?
----------------------

#### For all posts we should:

* [ ] Optionally tweet about the post from your personal account
* [ ] Re/tweet from @GoodEggsEng
* [ ] Post to Breaddit: http://goodeggs.meteor.com/submit
* [ ] Email <eng@goodeggs.com> a link to the blog, breaddit, and the tweet.
```
To: Engineering
Subject: [blog post] Good Eggs Goes Mobile

A series of posts about how the Good Eggs mobile site was built written by Adam and me.

Help spread the word!
Post - http://bites.goodeggs.com/posts/good-eggs-goes-mobile/
Breaddit - http://goodeggs.meteor.com/posts/KsJtJMNBY5QT6jiv2
Twitter - https://twitter.com/GoodEggsEng/status/461273753620455424

Thanks,
Michael
```

#### For posts that feel more substantial:

* [ ] Let the relevant project know about it (e.g. a post about Rivets)
 - post to google group
 - email the owner
 - stack overflow search
* [ ] Submit to Hacker News: https://news.ycombinator.com/submit
* [ ] Let Cathy and the marketing team <social@goodeggs.com> know the post exists so it can be included in relevant marketing emails (e.g. how the mobile site was made)
* [ ] Submit to JavaScript Weekly and/or Node Weekly: Email <peter@cooperpress.com>
![JavaScript Weekly Email Example](https://raw.githubusercontent.com/goodeggs/bites/master/src/files/images/javascript-weekly-example.png)


Want feedback before you post?
-----------------------
[Submit a pull request](https://github.com/goodeggs/bites/compare/) towards the issue you're writing about. This will give the team a chance to read it and give feedback before you publish.
