# Green Grocer

## Learning Goals

- Translate data from AoH to AoH
- Perform calculations based on AoH data

## Introduction

Over the last several lessons, we've explored nested data structures and how
they can model complex real-world situations. Now we're going to take everything
we've learned and use it to program a grocery store checkout process.

This lesson will be challenging. You're going to have to integrate everything
you've learned to this point, repetition, conditional flow control, analyzing
NDS, processing NDS, producing _insights_. On the other side of this challenge
you're going to _know_ that you _know_ how to construct and write procedural
style programs in Ruby.

In fact, and we're hesitant to say it, you're going to be irritated with us.
"Why is there so much boilerplate code, why are there so many
`while...do...end`s?" That's exactly where we want you to be. In the coming
lessons we'll show you refinements to clunky work that will make you and your
tired fingers so happy...but you'll appreciate them and what they do _in light
of_ this one last challenge.

So let's get to it!

## Shopping

Think for a moment about what it's like to shop at a grocery store. As you walk
through the store, you put the items you want to buy into your cart. Your cart,
then, becomes a _collection_ of grocery items. Every one of those grocery items
has specific _attributes_: for example, its price and whether or not it's on
clearance. You can also have multiples of the same item in your cart, and
chances are they will be all mixed in no particular order or structure.

> **Stop and Reflect**: When you read the paragraph above, did you hear the
> suggestion of an `Array` for a collection? Did the word _attributes_ suggest to
> you an attribute/value pair, like a `Hash`? If that's not happening for you
> at this moment, you should go back and review the first 4 lessons of this
> module.

When you pay for all your items at the checkout, you expect to get a
"consolidated" receipt that:

* lists all of the items you bought
* lists how many of each item you bought
* accounts for any coupons or discounts per item
* applies any "total price" discounts

> **Stop and Reflect**: You should recognize that there's a transformation
> happening between the NDS that represents "things in the cart" to the NDS
> that represents a "consolidated" receipt." You should be thinking about Steps
> 2, 3, and 4 of the NDS process we taught you. If that's not sounding
> familiar, review the lessons where we practice transforming NDS. Make sure
> your foundational skills are ready for this challenge!

In this lab, your task is to write a set of methods to handle the different
pieces of the checkout process and "wrap" them all inside of a `checkout`
method.

> **Stop and Reflect**: You should be thinking about `checkout` as an "Nth
> Order" method. You should be thinking about getting several "First Order"
> methods like `consolidate_cart` or `apply_coupons` in place. You might even
> be thinking about some methods that ***you*** think might be helpful along
> the way.

Use the tests to guide you to a solution!

## Grocery Items

Items in a cart will be represented as `Hash`es:

```ruby
{:item => "AVOCADO", :price => 3.00, :clearance => true}
```

## Carts

Carts are `Array`s of items.

## Coupon

```ruby
{:item => "AVOCADO", :num => 2, :cost => 5.00}
```

A coupon is represented as a `Hash`. Coupons only apply if the shopper has
purchased `:num` or more of the coupon.

## Instructions

Ultimately, we want to implement a method called `checkout` that will calculate
the total cost of a cart of items, applying discounts and coupons as necessary.

This `checkout` method will rely on three other methods: `consolidate_cart`,
`apply_coupons`, and `apply_clearance`.

Below find descriptions of each of the methods the tests will guide you to
create.

### Write the `find_item_by_name_in_collection` Method

* Arguments:
  * `String`: name of the item to find
  * `Array`: a collection of items to search through
* Returns:
  * `nil` if no match is found
  * the matching `Hash` if a match is found between the desired name and a given
    `Hash`'s :item key

### Write the `consolidate_cart` Method

* Arguments:
  * `Array`: a collection of item Hashes
* Returns:
  * a ***new*** `Array` where every ***unique*** item in the original is present
    * Every item in this new `Array` should have a `:count` attribute
    * Every item's `:count` will be _at least_ one
    * Where multiple instances of a given item are seen, the instance in the
      new `Array` will have its `:count` increased

_Example_:

Given:

```ruby
[
  {:item => "AVOCADO", :price => 3.00, :clearance => true },
  {:item => "AVOCADO", :price => 3.00, :clearance => true },
  {:item => "KALE", :price => 3.00, :clearance => false}
]
```

then the method should return the array below:

```ruby
[
  {:item => "AVOCADO", :price => 3.00, :clearance => true, :count => 2},
  {:item => "KALE", :price => 3.00, :clearance => false, :count => 1}
]
```

You'll be wanting to check in with tests often to make sure your method is on
track. If you want to run the tests about `consolidate_cart`, you can run them
by invoking `rspec spec/grocer_spec.rb:27`. If you look at the
`spec/grocer_spec.rb` file, you'll see that all the `consolidate_cart` tests
are in a `describe` block starting on line 27. This will help your output come
out in a digestible form.

You can apply this technique as you work through the various "First Order"
methods. Once you get a section working, be sure to run `learn` to make sure
that previous sections _remained_ working. This is called "Test-Driven
Development."  We can safely add new features because our tests tell us we
haven't broken the old ones.

### Write the `apply_coupons` Method

* Arguments:
  * `Array`: a collection of item `Hash`es
  * `Array`: a collection of coupon `Hash`es
* Returns:
  * A ***new*** `Array`. Its members will be a mix of the item `Hash`es and,
    where applicable, the "ITEM W/COUPON" `Hash`. Rules for application are
    described below.

_Example:_

Given:

```ruby
[
  {:item => "AVOCADO", :price => 3.00, :clearance => true, :count => 3},
  {:item => "KALE",    :price => 3.00, :clearance => false, :count => 1}
]
```

and an Array with a single coupon:

```ruby
[{:item => "AVOCADO", :num => 2, :cost => 5.00}]
```

then `apply_coupons` should change the first Array to look like:

```ruby
[
  {:item => "AVOCADO", :price => 3.00, :clearance => true, :count => 1},
  {:item => "KALE", :price => 3.00, :clearance => false, :count => 1},
  {:item => "AVOCADO W/COUPON", :price => 2.50, :clearance => true, :count => 2}
]
```

In this case, we have a 2 for $5.00 coupon and 3 avocados counted in the
consolidated cart. Since the coupon only applies to 2 avocados, the cart shows
there is one remaining avocado at full-price, $3.00, and a count of _2_
discounted avocados.

Note: we want to be consistent in the way our data is structured, so each item
in the consolidated cart should include the price of _one_ of that item. For
example, even though the coupon states $5.00—because there are 2 avocados—the
price is listed as $2.50.

### Write the `apply_clearance` Method

* Arguments:
  * `Array`: a collection of item `Hash`es
* Returns:
  * a ***new*** `Array` where every ***unique*** item in the original is present
    *but* with its price reduced by 20% if its `:clearance` value is `true`

This method should discount the price of every item on clearance by twenty
percent.

_Example:_

Given:

```ruby
[
  {:item => "PEANUT BUTTER", :price => 3.00, :clearance => true,  :count => 2},
  {:item => "KALE", :price => 3.00, :clearance => false, :count => 3},
  {:item => "SOY MILK", :price => 4.50, :clearance => true,  :count => 1}
]
```

it should update the cart with clearance applied to PEANUT BUTTER and SOY MILK:

```ruby
[
  {:item => "PEANUT BUTTER", :price => 2.40, :clearance => true,  :count => 2},
  {:item => "KALE", :price => 3.00, :clearance => false, :count => 3},
  {:item => "SOY MILK", :price => 3.60, :clearance => true,  :count => 1}
]
```

The `Float` class' built-in [round][round] method will be helpful here to make
sure your values align. `2.4900923090909029304` becomes `2.5` if we use it
like so: `2.4900923090909029304.round(2)`

### Write the `checkout` Method

* Arguments:
  * `Array`: a collection of item `Hash`es
  * `Array`: a collection of coupon `Hash`es
* Returns:
  * `Float`: a total of the cart

Here's where we stitch it all together. Given a "cart" `Array`, the first
argument, we should first create a new consolidated cart using the
`consolidate_cart` method.

We should pass the newly consolidated cart to `apply_coupons` and then send it to
`apply_clearance`. With all the discounts applied, we should loop through the
"consolidated and discounts-applied" cart and multiply each item Hash's price
by its count and accumulate that to a grand total.

As one last wrinkle, our grocery store offers a deal for customers buying lots
of items. If, after the coupons and discounts are applied, the cart's total is
over $100, the customer gets an additional 10% off. Apply this discount when
appropriate.

## Conclusion

When working with a lot of data, utilizing arrays and hashes is key. With our
knowledge of iteration and data manipulation, we can do all sorts of things
with this data. We can build methods that access that data and modify only what
we want. We can extract additional information, as we did here calculating a
total.  We can take data that isn't helpful to us and restructure it to be
_exactly_ what we need. Most importantly, we can process this data in a way
that lets us extract relevant insights that have meaning in the real world. The
better we can structure our programs to represent people and the actions they
need to perform, the easier we can make our programs necessary to users.

## Video Walkthrough

Try to solve this by yourself and give it your best, but if you 
get stuck checkout this video walkthrough:

<iframe width="640" height="480" src="https://www.youtube.com/watch?v=JAOL4dbtfLQ" frameborder="0" allowfullscreen></iframe>

## Resources

- [round][round]
- [Nested Data Structures to Insights](https://github.com/learn-co-curriculum/programming-univbasics-nds-nds-to-insights)

[round]: https://ruby-doc.org/core-2.1.2/Float.html#method-i-round

<p data-visibility='hidden'>View <a href='https://learn.co/lessons/green_grocer'>Green Grocer</a> on Learn.co and start learning to code for free.</p>
