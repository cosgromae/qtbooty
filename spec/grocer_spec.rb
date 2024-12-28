describe "Grocer" do
  # let() is like a global variable for tests
  let(:items) do
    [
      {:item => "AVOCADO", :price => 3.00, :clearance => true},
      {:item => "KALE", :price => 3.00, :clearance => false},
      {:item => "BLACK_BEANS", :price => 2.50, :clearance => false},
      {:item => "ALMONDS", :price => 9.00, :clearance => false},
      {:item => "TEMPEH", :price => 3.00, :clearance => true},
      {:item => "CHEESE", :price => 6.50, :clearance => false},
      {:item => "BEER", :price => 13.00, :clearance => false},
      {:item => "PEANUTBUTTER", :price => 3.00, :clearance => true},
      {:item => "BEETS", :price => 2.50, :clearance => false},
      {:item => "SOY MILK", :price => 4.50, :clearance => true}
    ]
  end

  let(:coupons) do
    [
      {:item => "AVOCADO", :num => 2, :cost => 5.00},
      {:item => "BEER", :num => 2, :cost => 20.00},
      {:item => "CHEESE", :num => 3, :cost => 15.00}
    ]
  end

  describe "#find_item_by_name_in_collection takes two arguments: a String and an AoH" do
    let(:test_cart) do
      [
        { :item => "DOG FOOD" },
        { :item => "WINE" },
        { :item => "STRYCHNINE" }
      ]
    end

    describe "and when a contained Hash's :item key matches the String" do
      it "returns the matching Hash" do
        expect(find_item_by_name_in_collection("WINE", test_cart)).to_not be_nil
        expect(find_item_by_name_in_collection("WINE", test_cart)).to eq({ :item => "WINE" })
      end
    end

    describe "but when no contained Hash's :item key matches the String" do
      it "returns the matching nil" do
        expect(find_item_by_name_in_collection("AXLE GREASE", test_cart)).to be_nil
      end
    end
  end

  describe "#consolidate_cart" do
    it "adds a count of one to each item when there are no duplicates" do
      cart = [find_item_by_name_in_collection('TEMPEH', items), find_item_by_name_in_collection('PEANUTBUTTER', items), find_item_by_name_in_collection('ALMONDS', items)]
      consolidated_cart = consolidate_cart(cart)
      i = 0
      while i < consolidated_cart.length do
        expect(consolidated_cart[i][:count]).to eq(1)
        i += 1
      end
    end

    it "increments count when there are multiple items" do
      avocado = find_item_by_name_in_collection('AVOCADO', items)
      cart = [avocado, avocado, find_item_by_name_in_collection('KALE', items)]

      consolidated_cart = consolidate_cart(cart)
      av = find_item_by_name_in_collection("AVOCADO", consolidated_cart)
      expect(av[:price]).to eq(3.00)
      expect(av[:clearance]).to eq(true)
      expect(av[:count]).to eq(2)

      hipster_lettuce = find_item_by_name_in_collection("KALE", consolidated_cart)
      expect(hipster_lettuce[:price]).to eq(3.00)
      expect(hipster_lettuce[:clearance]).to eq(false)
      expect(hipster_lettuce[:count]).to eq(1)
    end
  end

  describe "#apply_coupons" do
    context "base case - with perfect coupon (number of items identical):" do
      it "adds a new key, value pair to the cart hash called 'ITEM NAME W/COUPON'" do
        item_name = "AVOCADO"
        item_with_coupon_applied_name = "#{item_name} W/COUPON"
        avocado = find_item_by_name_in_collection(item_name, items)
        avocado_coupon = coupons.first
        perfect_avocado_cart = [ avocado, avocado ]
        consolidated_cart = consolidate_cart(perfect_avocado_cart)
        coupon_applied_cart = apply_coupons(consolidated_cart, [avocado_coupon])
        found_item = find_item_by_name_in_collection(item_with_coupon_applied_name, coupon_applied_cart)
        expect(found_item).to_not be_nil, "After applying valid coupons make sure you add the applied coupon Hash"
      end

      it "adds the coupon price to the property hash of couponed item" do
        item_name = "AVOCADO"
        item_with_coupon_applied_name = "#{item_name} W/COUPON"
        avocado = find_item_by_name_in_collection(item_name, items)
        avocado_coupon = coupons.first
        perfect_avocado_cart = [ avocado, avocado ]
        consolidated_cart = consolidate_cart(perfect_avocado_cart)
        coupon_applied_cart = apply_coupons(consolidated_cart, [avocado_coupon])
        found_item = find_item_by_name_in_collection(item_with_coupon_applied_name, coupon_applied_cart)
        expect(found_item[:price]).to eq(2.50), "After applying a $5 for 2 coupon to avocadoes, the price per unit is 2.50"
      end

      it "adds the count number to the property hash of couponed item" do
        item_name = "AVOCADO"
        item_with_coupon_applied_name = "#{item_name} W/COUPON"
        avocado = find_item_by_name_in_collection(item_name, items)
        avocado_coupon = coupons.first
        perfect_avocado_cart = [ avocado, avocado ]
        consolidated_cart = consolidate_cart(perfect_avocado_cart)
        coupon_applied_cart = apply_coupons(consolidated_cart, [avocado_coupon])
        found_item = find_item_by_name_in_collection(item_with_coupon_applied_name, coupon_applied_cart)
        expect(found_item[:count]).to eq(2), "The coupon's count should remain unchanged"
      end

      it "removes the number of discounted items from the original item's count" do
        item_name = "AVOCADO"
        avocado = find_item_by_name_in_collection(item_name, items)
        avocado_coupon = coupons.first
        perfect_avocado_cart = [ avocado, avocado ]
        consolidated_cart = consolidate_cart(perfect_avocado_cart)
        coupon_applied_cart = apply_coupons(consolidated_cart, [avocado_coupon])
        original_item = find_item_by_name_in_collection(item_name, coupon_applied_cart)
        expect(original_item[:price]).to eq(3.00)
        expect(original_item[:count]).to eq(0)
      end

      it "remembers if the item was on clearance" do
        item_name = "AVOCADO"
        item_with_coupon_applied_name = "#{item_name} W/COUPON"
        avocado = find_item_by_name_in_collection(item_name, items)
        avocado_coupon = coupons.first
        perfect_avocado_cart = [ avocado, avocado ]
        consolidated_cart = consolidate_cart(perfect_avocado_cart)
        coupon_applied_cart = apply_coupons(consolidated_cart, [avocado_coupon])
        found_item = find_item_by_name_in_collection(item_with_coupon_applied_name, coupon_applied_cart)
        expect(found_item[:clearance]).to eq(true)
      end
    end

    context "more advanced cases:" do
      it "doesn't break if the coupon doesn't apply to any items" do
        cheese = find_item_by_name_in_collection('CHEESE', items)
        cart = [cheese, cheese]

        consolidated_cart = consolidate_cart(cart)
        cheese_item = find_item_by_name_in_collection("CHEESE", consolidated_cart)

        expect(cheese_item[:price]).to eq(6.50)
        expect(cheese_item[:count]).to eq(2)
        expect(find_item_by_name_in_collection("AVOCADO", cart)).to be_nil, "Didn't get any avocadoes!"
        expect(find_item_by_name_in_collection("AVOCADO W/COUPON", cart)).to be_nil, "No avacados on which to apply a coupon"
      end

      it "can apply multiple coupons" do
        avocado = find_item_by_name_in_collection("AVOCADO", items)
        cheese = find_item_by_name_in_collection("CHEESE", items)
        cart = [
          cheese, cheese, cheese, cheese,
          avocado, avocado, avocado
        ]
        consolidated_cart = consolidate_cart(cart)
        test_coupons = [coupons.first, coupons.last]

        coupon_applied_cart = apply_coupons(consolidated_cart, test_coupons)

        cheese = find_item_by_name_in_collection("CHEESE", coupon_applied_cart)
        cheese_wc = find_item_by_name_in_collection("CHEESE W/COUPON", coupon_applied_cart)
        avocado = find_item_by_name_in_collection("AVOCADO", coupon_applied_cart)
        avocado_wc = find_item_by_name_in_collection("AVOCADO W/COUPON", coupon_applied_cart)

        expect(cheese[:price]).to eq(6.50)
        expect(avocado[:price]).to eq(3.00)
        expect(cheese_wc[:price]).to eq(5.00)
        expect(cheese_wc[:count]).to eq(3)
        expect(cheese_wc[:clearance]).to eq(false)
        expect(avocado_wc[:price]).to eq(2.50)
        expect(avocado_wc[:count]).to eq(2)
        expect(avocado_wc[:clearance]).to eq(true)
      end

      it "doesn't break if there is no coupon" do
        cheese = find_item_by_name_in_collection('CHEESE', items)
        cart = [cheese, cheese]
        consolidated_cart = consolidate_cart(cart)
        coupon_applied_cart = apply_coupons(consolidated_cart, [])

        cheese_in_cart = find_item_by_name_in_collection("CHEESE", coupon_applied_cart)

        expect(cheese_in_cart[:price]).to eq(6.50)
        expect(cheese_in_cart[:count]).to eq(2)
      end

    end
  end

  describe "#apply_clearance" do
    it "takes 20% off price if the item is on clearance" do
      cart = [find_item_by_name_in_collection('TEMPEH', items)]
      consolidated_cart = consolidate_cart(cart)

      clearance_applied_cart = apply_clearance(consolidated_cart)
      expect(clearance_applied_cart.first[:price]).to be_within(0.1).of(2.40)
    end

    it "does not discount the price for items not on clearance" do
      cart = [
        find_item_by_name_in_collection('AVOCADO', items),
        find_item_by_name_in_collection('TEMPEH', items),
        find_item_by_name_in_collection('BEETS', items),
        find_item_by_name_in_collection('SOY MILK', items)
      ]
      consolidated_cart = consolidate_cart(cart)
      clearance_applied_cart = apply_clearance(consolidated_cart)
      clearance_prices = {"AVOCADO" => 2.40, "TEMPEH" => 2.40, "BEETS" => 2.50, "SOY MILK" => 3.60}

      i = 0
      while  i < clearance_applied_cart.length do
        item = clearance_applied_cart[i]
        expect(item[:price]).to be_within(0.1).of(clearance_prices[item[:item]])
        i += 1
      end
    end
  end

  describe "#checkout" do
    describe "in base case (no clearance, no coupons)" do
      it "calls on #consolidate_cart before calculating the total for one item" do
        cart = [find_item_by_name_in_collection('BEETS', items)]
        expect(checkout(cart, [])).to eq(2.50)
      end

      it "calls on #apply_coupons after calling on #consolidate_cart when there is only one item in the cart" do
        cart = [find_item_by_name_in_collection('BEETS', items)]

        expect(checkout(cart, [])).to eq(2.50)
      end

      it "calls on #apply_clearance after calling on #apply_coupons when there is only one item in the cart and no coupon" do
        cart = [find_item_by_name_in_collection('BEETS', items)]

        consolidated_cart = consolidate_cart(cart)
        coupon_applied_cart = apply_coupons(consolidated_cart, [])
        clearance_applied_cart = apply_clearance(coupon_applied_cart)


        expect(checkout(clearance_applied_cart, [])).to eq(2.50)
      end

      it "calls on #apply_clearance after calling on #apply_coupons with multiple items and one coupon" do
        beer = find_item_by_name_in_collection('BEER', items)
        beets = find_item_by_name_in_collection('BEETS', items)
        cart = [beets, beer, beer, beer]
        coupon_collection = [coupons[1]]

        expect(checkout(cart, coupon_collection)).to eq(35.50)
      end

      it "calls on #apply_clearance after calling on #apply_coupons with multiple items, coupons, and items are on clearance" do
        avocado = find_item_by_name_in_collection("AVOCADO", items)
        cheese =  find_item_by_name_in_collection("CHEESE", items)
        milk =    find_item_by_name_in_collection("SOY MILK", items)

        cart = [milk, avocado, avocado, cheese, cheese, cheese]

        expect(checkout(cart, [coupons.first, coupons.last])).to eq(22.60)
      end

      it "calls on #consolidate_cart before calculating the total for two different items" do
        cart = [find_item_by_name_in_collection('CHEESE', items), find_item_by_name_in_collection('BEETS', items)]
        consolidated_cart = consolidate_cart(cart)
        expect(checkout(consolidated_cart, [])).to eq(9.00)
      end

      it "calls on #consolidate_cart before calculating the total for two identical items" do
        beets = find_item_by_name_in_collection('BEETS', items)
        cart = [beets, beets]
        expect(checkout(cart, [])).to eq(5.00)
      end
    end

    describe "coupons:" do
      it "considers coupons" do
        cheese = find_item_by_name_in_collection('CHEESE', items)
        cart = [cheese, cheese, cheese]
        c = [coupons.last]
        expect(checkout(cart, c)).to eq(15.00)
      end

      it "considers coupons and clearance discounts" do
        avocado = find_item_by_name_in_collection('AVOCADO', items)
        cart = [avocado, avocado]
        c = [coupons.first]
        expect(checkout(cart, c)).to eq(4.00)
      end

      it "only applies coupons that meet minimum amount" do
        beer = find_item_by_name_in_collection('BEER', items)
        cart = [beer, beer, beer]
        beer_coupon = coupons[1]
        coupons = [beer_coupon, beer_coupon]
        expect(checkout(cart, coupons)).to eq(33.00)
      end
    end

    describe "clearance:" do
      it "applies a 20% discount to items on clearance" do
        cart = [find_item_by_name_in_collection('PEANUTBUTTER', items)]
        total_cost = checkout(cart, [])
        expect(total_cost).to eq(2.40)
      end

      it "applies a 20% discount to items on clearance but not to non-clearance items" do
        cart = [find_item_by_name_in_collection("BEETS", items), find_item_by_name_in_collection("PEANUTBUTTER", items)]
        total_cost = checkout(cart, [])
        expect(total_cost).to eq(4.90)
      end
    end

    describe "discount of ten percent" do
      it "applies 10% discount if cart over $100" do
        beer = find_item_by_name_in_collection('BEER', items)
        cart = []
        10.times { cart << beer }
        expect(checkout(cart, [])).to eq(117.00)
      end
    end
  end
end
