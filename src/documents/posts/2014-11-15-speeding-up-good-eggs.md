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

# Why it was slow

### 1) We had built a large client side app

The first issue was that we built a large client side app that needed to be downloaded and run for you to see products. This meant that our page load life-cycle looked something like this:

1. Download the client-side app
2. The app starts up and determines what it needs to show
3. We download the data that needs to be shown
4. We take the responses from the server and render them in your browser
5. You can now see products and even buy them

When we looked at how to make things faster, we realized that no matter how fast all of this happened, we would still be seeing page load times close to 1 second even if we tuned the snot out of everything.


### 2) Determining what products to show on a page was hard at the time

MongoDb is our datastore of choice and the data we need to figure out if a product is available is scattered into 5 collections, and with the way things were structured at the time, it meant 5 or more queries were needed to show you products. On top of this, we needed to stich all this data together in memory to figure out if we could show products.


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

1. node & coffeescript
2. mongo db & mongoose for mappings, validations and other interesting things
3. backbone and LOTS of client side rendering with ajax calls to fetch the data


## The Complexities
Working with thousands of local producers, most of them very small and early on in their business comes with a very interesting set of challenges. Many of our producers would have trouble fulfilling orders every day of the week or on short notice, so we have schedules of when they can be here to drop food off and how much lead time they need to make their products.

Lots of people that we work with do this as a part-time job or have limited access to kitchens to make their foods or for some farmers, they might have limited access to trucks to bring thier produce to the city.

On top of this, lots of our producers can't (yet) opperate at large scale, so they need to make sure they don't get more orders than they can fulfill on any given day.

Because of this we have some very flexible rules to determine if a product can be sold.

The rules generally follow this parrern right now when determining if a product can be ordered for a specific day:

1. Is Good Eggs open on the day?
2. Is it before the market wide order deadline for the day?
3. Is the producer actively selling (some are a seasonal business)?
3. Does the producer fulfill orders on this day?
4. Is it before the producers custom order deadline for the day (if they have one)?
5. Is the product available for sale (as opposed to discontinued or out of season for example)?
5. Does the producer have the capacity to make and sell any for the day?

(That last one sounds simple, but is actually by-far the most complex, involving a fair amount of processing)

At the time, all this data lived in MongoDb and it was spread out across 4 collections:
* `vendors` contains the status & schedule information for the producers
* `foodhubs` contains the schedule for the overall market
* `products` contains the product details and status
* `product_availabilities` contains the rules and quantity remaining for products over time periods. This is where we would know if something was sold out or no longer available

So, answering the question "how many of this product can we sell on tuesday?" involves getting data from 4 separate collections in mongo, joining it together in memory and performing more calculations than we really have any business doing to show a list of products to you. What made this even worse, is that we had to query for and return all of the products even if they were not available in order to find out what products could actually be sold on a given day. The worst part about this is that most of these queries had to be done syncronously.

For example, getting the list of products to display in the San Francisco produce section would go something like this:

1. load the foodhub (this happens on most requests and isn't really a problem)
2. after that, load all the products tagged in the 'produce' category
3. after that, load all the vendors for thoes products based on the vendor id on the products
4. in parallel, load all the availability rules for the products

Needless to say, this was excruciatingly slow and it was happening on nearly every page view.


## Denormalization to the rescue

Our solution to this was to do all of the complex calculations behind the sceens and store the results in a separate collection that we optimized for querying and displaying products in the marketplace. We call them `MarketProduct`s. This data is read-only and contains flattened out availability data and everything else we would need to show a product in the marketplace.

Here's roughly what the one for Josey Baker's Break of the Week looks like:

    { _id: 4f4eeeb1112637040000005c,
      cacheKey: '98d28fb8e06962b471285ed554b2e95f',
      foodshed: 'sfbay',
      name: 'Bread of the Week',
      price: 5.99,
      slug: 'bread-of-the-week',
      sectionOrder:
       { breads: 1,
         'organic-ingredients': 4,
         'local-business': 2 },
      status: 'available',
      availabilities:
       [ { day: '2014-11-08', status: 'unavailable' },
         { day: '2014-11-09', status: 'unavailable' },
         { day: '2014-11-10', quantity: Infinity, cutoff: 1415520000000, status: 'available' },
         { day: '2014-11-11', quantity: Infinity, cutoff: 1415606400000, status: 'available' },
         { day: '2014-11-12', quantity: Infinity, cutoff: 1415692800000, status: 'available' },
         { day: '2014-11-13', quantity: Infinity, cutoff: 1415779200000, status: 'available' },
         { day: '2014-11-14', status: 'unavailable' } ],
      tags:
       [ 'Breads',
         'Local Business',
         'Organic Ingredients' ],
      categories: [ 'bakery' ],
      vendor:
       { name: 'Josey Baker Bread',
         slug: 'joseybakerbread',
         city: 'San Francisco, CA',
         photo: { key: 'vendor_photo/6uziaPPTweSl4wmVIk6A_joseybakerbread.jpg' } },
      photos:
       [ { key: 'product_photos/nT2iqPL7QwajWI0f8hev_bread.jpg' },
         { key: 'product_photos/MpnwEYhIQraUgunsx46O_bread6.jpg' },
         { key: 'product_photos/X53TRtYiTBWypRhSgtXB_bread7.jpg', },
         { key: 'product_photos/rAkPotPTFqBibeNw5cRM_bread8.jpg', },
         { key: 'product_photos/GGrFXMgHQ2S3YFTjFMYM_bread9.jpg', } ] }


There are some pretty important things going on here...

1. We've used the schedules and availabilities to pre-calculate the quantities available over the next week in a way that we can query them. You can see this under the `availabilities` property.
2. The key vendor information is embedded in this structure so we don't have to query for it in order to show their image and a link to their webstand
3. We have a list of the categories and tags that this product should show up under. You can see this in the `categories` and `tags` properties.
4. We have pre-calculated the products sort order for different areas of the site. You can see this in the `sectionOrder` property.

All of this means that we can now execute one query and get back exactly the list of products we want to show, even if the customer wants to filter by a future shopping day because they might be adding to a subscription.

This means we can get all of the products available to buy on the day before thanksgiving like this:

      MarketProduct.sync.find
        category: 'thanksgiving'
        foodshed: 'sfbay'
        availabilities:
          $elemMatch:
            day: '2014-11-16'
            cutoff: $gt: new Date()
            status: 'availabile'

For thoes of you that have never used it before `$elemMatch` in MongoDB works something like a subquery in a SQL database would. It looks for one entry in the `availabilities` arrray that matches all the criteria. It allows us to query for a day where the product is for sale and the order deadline (`cutoff`) has not passed. It also allows us to index this data well, whereas an approach with the date string as the field name


## Keeping `MarketProduct`s up to date

On the backend, we have a set of what we refer to as observers. These are hooked into the mongoose post save hooks and perform some work asyncronously. So, essentially they give us a chance to update related things when something changes. In this case, we are watching changes to `Product`, `Vendor` and `ProductAvailabilityConstraint` and when they change, we rebuild the `MarketProducts` that are related. This keeps the market in sync with the changes to any of the related data.

