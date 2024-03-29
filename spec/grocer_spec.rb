require 'spec_helper'

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
    it "adds 20% discount to items currently on clearance" do
      # Clearance item
      pb = items.find { |item| item['PEANUTBUTTER'] }
      cart = [pb]
      result = consolidate_cart(cart)
      total_cost = checkout(cart: result, coupons: [])

      expect(total_cost).to eq(2.80)
    end

    it "considers coupons" do
      avocado = items.find { |item| item['AVOCADO'] }
      cart = [avocado, avocado]
      
      avocado_coupon = coupons.find {|coupon| coupon[:item] == "AVOCADO" }
      coupons = [avocado_coupon]

    end

    it "triples discount if 2 coupons present" do
      avocado = items.find { |item| item['AVOCADO'] }
      cart = [avocado, avocado]
      avocado_coupon = coupons.find {|coupon| coupon[:item] == "AVOCADO" }
      coupons = [avocado_coupon, avocado_coupon]
    end

    it "charges full price for items that fall outside of coupon count" do
      beer = items.find { |item| item['BEER'] }
      cart = [beer, beer, beer]
      beer_coupon = coupons.find {|coupon| coupon[:item] == "BEER" }
      coupons = [beer_coupon, beer_coupon]
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
