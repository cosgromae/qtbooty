---
languages: ruby
tags: collections, arrays, hashes
---

##Objectives: 
Create a checkout method to calculate the total cost of a cart of items and apply discounts and coupons as necessary.

Dr. Steve Bruhle, your green grocer, isn't ready, but you are!

##Skills: 
any?, all?, none?, each, map/collect

##Instructions:

Implement a method `checkout` to calculate total cost of a cart of items and apply discounts and coupons as necessary.

### The `consolidate_cart` method

The cart starts as an array of individual items. Translate it into a hash that includes the counts for each item with the `consolidate_cart` method.

### The `checkout` method

Create a `checkout` method that calculates the total cost of the consolidated cart.

When checking out, check the coupons and apply the discount if the proper number of items is present.

* If any of the items are on clearance add a 20% discount.

* If the customer has 2 of the same coupon, triple the discount.

* If none of the items purchased have a unit price greater than $5 give the customer a 10$ discount off the whole cart

#Reward
https://www.youtube.com/watch?v=-RuSCACXmXs
