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
Code generates a random cart of items and a random set of coupons. Implement a method checkout to calculate total cost of a cart of items and apply discounts and coupons as necessary.

##Code:

```ruby
ITEMS = [  {"AVOCADO" => {:price => 3.00, :clearance => true}},
     {"KALE" => {:price => 3.00,:clearance => false}},
     {"BLACK_BEANS" => {:price => 2.50,:clearance => false}},
     {"ALMONDS" => {:price => 9.00, :clearance => false}},
     {"TEMPEH" => {:price => 3.00,:clearance => true}},
     {"CHEESE" => {:price => 6.50,:clearance => false}},
     {"BEER" => {:price => 13.00, :clearance => false}},
     {"PEANUTBUTTER" => {:price => 3.00,:clearance => true}},
     {"BEETS" => {:price => 2.50,:clearance => false}}]

COUPS = [  {:item=>"AVOCADO", :num=>2, :cost=>5.00},
     {:item=>"BEER", :num=>2, :cost=>20.00},
     {:item=>"CHEESE", :num=>3, :cost=>15.00}]

#randomly generates a cart of items
def generate_cart
 cart = []
 rand(20).times do
   cart.push(ITEMS.sample)
 end
 cart
end

#randomly generates set of coupons
def generate_coups
 coups = []
 rand(2).times do
   coups.push(COUPS.sample)
 end
 coups
end

```

The cart is currently an array of individual items. Translate it into a hash that includes the counts for each item.

For example if your cart was:
``` ruby 
[
	{
		"AVOCADO" => {
			:price => 3.00, 
			:clearance => true
		}
	}, 
	{ 
		"AVOCADO" => {
			:price => 3.00, 
			:clearance => true
		}
	}
]
```

...becomes: 

``` ruby 
{
	"AVOCADO" => {
		:price => 3.00, 
		:clearance => true
	}, 
	:count => 2
}
```

### The `checkout` method

Create a `checkout` method that calculates the total cost of the cart.
When checking out, check the coupons and apply the discount if the proper number of items is present.

If any of the items are on clearance add a 20% discount.
If the customer has 2 of the same coupon, triple the discount.
If none of the items purchased have a unit price greater than $5 give the customer a 10$ discount off the whole cart

#Reward
https://www.youtube.com/watch?v=-RuSCACXmXs
