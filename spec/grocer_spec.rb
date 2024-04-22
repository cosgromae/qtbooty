require 'spec_helper'
require_relative '../grocer.rb'

describe "Grocer" do
  let(:items) do
    [
        {"AVOCADO" => {:price => 3.00, :clearance => true}},
        {"KALE" => {:price => 3.00, :clearance => false}},
        {"BLACK_BEANS" => {:price => 2.50, :clearance => false}},
        {"ALMONDS" => {:price => 9.00, :clearance => false}},
        {"TEMPEH" => {:price => 3.00, :clearance => true}},
        {"CHEESE" => {:price => 6.50, :clearance => false}},
        {"BEER" => {:price => 13.00, :clearance => false}},
        {"PEANUTBUTTER" => {:price => 3.00, :clearance => true}},
        {"BEETS" => {:price => 2.50, :clearance => false}}
    ]
  end

  let(:coupons) do
    [
        {:item => "AVOCADO", :num => 2, :cost => 5.00},
        {:item => "BEER", :num => 2, :cost => 20.00},
        {:item => "CHEESE", :num => 3, :cost => 15.00}
    ]
  end

  describe "consolidate_cart" do
    it "consolidates cart with multiple items" do
      # items comes from the rspec "let" above.

      avocado = items.find { |item| item['AVOCADO'] }
      kale = items.find { |item| item['KALE'] }
      cart = [avocado, avocado, kale]

      result = consolidate_cart(cart)

      expected_consolidated_cart = {
          "AVOCADO" => {
              :price => 3.00,
              :clearance => true,
              :count => 2
          },
          "KALE" => {
              :price => 3.00,
              :clearance => false,
              :count => 1
          }
      }
      expect(result).to eq(expected_consolidated_cart)
    end
  end

  describe "checkout" do

    it "consolidates cart before calculation" do
      beets = items.find { |item| item['BEETS'] }
      cart = [beets]
      expect(self).to receive(consolidate_cart) { cart }
      expect(checkout(cart: cart, coupons: [])).to eq(2.50)
    end

    it "adds 20% discount to items currently on clearance" do
      # Clearance item
      pb = items.find { |item| item['PEANUTBUTTER'] }
      cart = [pb]
      total_cost = checkout(cart: cart, coupons: [])

      expect(total_cost).to eq(2.80)
    end

    it "considers coupons" do
      avocado = items.find { |item| item['AVOCADO'] }
      cart = [avocado, avocado]
      
      avocado_coupon = coupons.find {|coupon| coupon[:item] == "AVOCADO" }
      coupons = [avocado_coupon]
      expect(checkout(cart: cart, coupons: coupons)).to eq(5.00)
    end

    it "charges full price for items that fall outside of coupon count" do
      beer = items.find { |item| item['BEER'] }
      cart = [beer, beer, beer]

      beer_coupon = coupons.find {|coupon| coupon[:item] == "BEER" }
      coupons = [beer_coupon]

      expect(checkout(cart: cart, coupons: coupons)).to eq(33.00)
    end


    it "only applies coupons that meet minimum amount" do
      beer = items.find { |item| item['BEER'] }
      cart = [beer, beer, beer]

      beer_coupon = coupons.find {|coupon| coupon[:item] == "BEER" }
      coupons = [beer_coupon, beer_coupon]

      expect(checkout(cart: cart, coupons: coupons)).to eq(33.00)
    end

    it "applies 10% discount if cart over $100" do
      beer = items.find { |item| item['BEER'] }
      cart = []
      
      10.times { cart << beer }
      
      result = consolidate_cart(cart)

      expect(checkout(result)).to eq(130.00)
    end
  end
end

#randomly generates a cart of items
# def generate_cart
#  cart = []
#  rand(20).times do
#    cart.push(ITEMS.sample)
#  end
#  cart
# end

# #randomly generates set of coupons
# def generate_coups
#  coups = []
#  rand(2).times do
#    coups.push(COUPS.sample)
#  end
#  coups
# end
