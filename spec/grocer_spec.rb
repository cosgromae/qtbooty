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

      result = consolidate_cart(cart: cart)

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
    describe "using the consolidate_cart method during checkout" do
      it "consolidates cart before calculation" do
        beets = items.find { |item| item['BEETS'] }
        cart = [beets]
        result = consolidate_cart(cart: cart)

        expect(self).to receive(:consolidate_cart).with(cart: cart).and_return(result)
        expect(checkout(cart: cart, coupons: [])).to eq(2.50)
      end
    end

    it "adds 20% discount to items currently on clearance" do
      # Clearance item
      pb = items.find { |item| item['PEANUTBUTTER'] }
      cart = [pb]
      total_cost = checkout(cart: cart, coupons: [])

      expect(total_cost).to eq(2.40)
    end

    it "considers coupons" do
      cheese = items.find { |item| item['CHEESE'] }
      cart = [cheese, cheese, cheese]
      
      cheese_coupon = coupons.find {|coupon| coupon[:item] == "CHEESE" }
      coupons = [cheese_coupon]

      expect(checkout(cart: cart, coupons: coupons)).to eq(15.00)
    end

    it "considers coupons and clearance discounts" do
      avocado = items.find { |item| item['AVOCADO'] }
      cart = [avocado, avocado]
      
      avocado_coupon = coupons.find {|coupon| coupon[:item] == "AVOCADO" }
      coupons = [avocado_coupon]

      expect(checkout(cart: cart, coupons: coupons)).to eq(4.00)
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

      expect(checkout(cart: cart, coupons: [])).to eq(117.00)
    end
  end
end
