---
title: speeding up good eggs
author: Joe Sadowski
layout: post
disqus:
  shortname: goodeggsbytes
  url: "http://bites.goodeggs.com/post/speeding-up-good-eggs"
---

How we sped up our market.

For thoes of you that have been shopping with us at good eggs for a while now, you might recall the old site. It looked something like this:


And it was slow.

We decided to do something about that a few months ago and here's how we've managed to speed thing up significantly...

# Our Infastructure at the Time

1) node & coffeescript
2) mongo db & mongoose for mappings, validations and other interesting things
3) backbone and LOTS of client side rendering with ajax calls to fetch the data


# The Complexities
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


# Doing Something About It

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

On the backend, we have a set of what we refer to as observers. These are hooked into the mongoose post save hooks and perform some work asyncronously. So, essentially they give us a chance to update related things when something changes. In this case, we are watching changes to `Product`, `Vendor` and `ProductAvailabilityConstraint` and when they change, we rebuild the `MarketProducts` that are related. This keeps the market in sync with the changes to the products..