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

When checking out 

* Apply coupon discounts if the proper number of items are present

* Apply 20% discount if items are on clearance

* If cart's total is over $100, apply 10% discount. Apply coupons first, then check total.

#Reward
https://www.youtube.com/watch?v=-RuSCACXmXs
