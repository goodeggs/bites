---
title: speeding up good eggs
author: Joe Sadowski
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/speeding-up-good-eggs"
---

1. The problems
  * client side app boot up time and loop back
  * server side listing of products was taking a long time
  * client side rendering was taking a long time

2. Moving things server side
  * a responsive reskin of our mobile app
  * eliminating round-trips on first load

3. Introducing MarketProduct
  * Availabilities
  * How market products are structured
  * How we query them
  * How and when we rebuild them

4. Introducing ProductTiles
  * why: rendering our templates on large pages was slow
  * what a tile is
  * cache key
  * punching in availability
  * getting tiles workflow (mget redis query)
  * invalidating and regenerating old tiles

5. Covered Queries in Mongo
 * adding key data to mongo indexes

# --------


For thoes of you that have been shopping with us at good eggs for a while now, you might recall the old site. It looked something like this:


And it was slow. Slow like molasses in the winter.

With our rebuild of the site, we had a few things we wanted to make sure we accomplished:

1. The new site had to be responsive. We were all tired of making changes in our desktop codebase and our mobile codebase at the time and they were even starting to diverge a bit
2. Performace needed to improve

We'll talk mostly about the perfomance here, but it helps to undertand that we also wanted to make sure we're building for more devices in the future.


So, now onto performance...

## Why it was slow

### 1) We had built a large client side app

The first issue was that we built a large client side app that needed to be downloaded and run for you to see products. This meant that our page load life-cycle looked something like this:

1. Download the client-side app
2. The app starts up and determines what it needs to show
3. We download the data that needs to be shown
4. We take the responses from the server and render them in your browser
5. You can now see products and even buy them

When we looked at how to make things faster, we realized that no matter how fast all of this happened, we would still be seeing page load times close to 1 second even if we tuned the snot out of everything.


### 2) Determining what products to show on a page was hard at the time

MongoDb is our datastore of choice and the data we need to figure out if a product is available is scattered into 5 collections, and with the way things were structured at the time, it meant 5 or more queries were needed to show you products and that we needed to stich all this data together somehow to figure out what was available and how it should be shown.


### 3) Generating the html for products was surprisingly time-consuming

Once we moved things server side and were able to quickly retrieve the right list of products to show you, we realized that the majority of our time was being spent generating html to send to the client. This really concearned us, since it would essentialy block the node process for nearly a full second at a time on large pages, meaning we could queue up a lot of requests and easily overload our servers CPU in production. Not a great idea!




# Moving Client Side

Earlier this year we had built a mobile optimized site (and we even wrote about how we built it) that happened to already be generating html server side. Since we also wanted things to be responsive, we chose this as our starting point.


-----------------------------------------

## Our problems at the time

Our original marketplace was built for producers to sell diretly and wasn't initially designed to show or work with the number of products we currently offer. This made development rather slow and not all of the code made sense the way it was used.


This and the fact that it was a large client side app lead to less than ideal performance. We really had these problems:


So, in essence we had a few real problems:
1. the app wa
1. client side app boot up time
2. client side rendering was taking a long time
3. server side listing of products was taking a long time


## Our Infastructure at the Time

1) node & coffeescript
2) mongo db & mongoose for mappings, validations and other interesting things
3) backbone and LOTS of client side rendering with ajax calls to fetch the data


## The Complexities
Working with thousands of local producers, most of them very small and early on in their business comes with a very interesting set of challenges. Many of our producers would have trouble fulfilling orders every day of the week or on short notice, so we have schedules of when they can be here to drop food off and how much lead time they need to make their products.

Lots of people that we work with do this as a part-time job or have limited access to kitchens to make their foods or for some farmers, they might have limited access to trucks to bring thier produce to the city.

On top of this, lots of our producers can't (yet) opperate at large scale, so they need to make sure they don't get more orders than they can fulfill on any given day.

Because of this we have what ends up being a very powerful rules engine for determining if something can be sold on a given day.

The rules generally follow this parrern right now when determining if a product can be ordered for a specific day:

1) Is Good Eggs open on the day?
2) Is it before the market wide order deadline for the day?
3) Does the producer fulfill orders on this day?
4) Is it before the producers custom order cutoff for the day (if they have one)?
5) Can the producer still make and sell any for the day?

(That last one sounds simple, but is actually by-far the most complex)

All in, answering the question "how many of this product can we sell on tuesday?" involves getting data from 4 separate collections in mongo, join it all together in memory and perform more calculations than we really have any business doing to show a list of products to you. What made this even worse, is that we had to query for and return all of the products even if they were not available in order to find out what products could actually be sold on a given day.

Needless to say, this was excruciatingly slow.


## Doing Something About It

We decided what we needed was to make sure everything we were using to determine what list of products to show was pre-calculated so we could query in mongo to see what products are available on any given upcoming day.

We ended up with something called MarketProduct and a schema like this:

    _id: # matches the traditional product id
    name:
    slug:
    vendor:
      name:
      slug:
    availabilities: [
      day:
      status:
      cutoff:
      quantity:
    ]
    tags: []
    categories: []

This means we can get all of the products available to buy on the day before thanksgiving like this:

      MarketProduct.sync.find
        category: 'thanksgiving'
        foodshed: 'sfbay'
        availability:
          $elemMatch:
            day: '2014-11-16'
            cutoff: $gt: new Date()
            status: 'availabile'

On the backend, we have a set of what we refer to as observers. These are hooked into the mongoose post save hooks and perform some work asyncronously. So, essentially they give us a chance to update related things when something changes. In this case, we are watching changes to `Product`, `Vendor` and `ProductAvailabilityConstraint` and when they change, we rebuild the `MarketProducts` that are related. This keeps the market in sync with the changes to any of the related data.

