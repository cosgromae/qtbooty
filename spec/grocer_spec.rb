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
      {"BEETS" => {:price => 2.50, :clearance => false}},
      {"SOY MILK" => {:price => 4.50, :clearance => true}}
    ]
  end

  let(:coupons) do
    [
      {:item => "AVOCADO", :num => 2, :cost => 5.00},
      {:item => "BEER", :num => 2, :cost => 20.00},
      {:item => "CHEESE", :num => 3, :cost => 15.00}
    ]
  end

  describe "#consolidate_cart" do
    it "adds a count of one to each item when there are no duplicates" do
      cart = [find_item('TEMPEH'), find_item('PEANUTBUTTER'), find_item('ALMONDS')]
      result = consolidate_cart(cart)
      result.each do |item, attributes|
        expect(attributes.keys).to include(:count)
        expect(attributes[:count]).to eq(1)
      end
    end

    it "increments count when there are multiple items" do
      avocado = find_item('AVOCADO')
      cart = [avocado, avocado, find_item('KALE')]

      result = consolidate_cart(cart)
      expect(result["AVOCADO"][:price]).to eq(3.00)
      expect(result["AVOCADO"][:clearance]).to eq(true)
      expect(result["AVOCADO"][:count]).to eq(2)

      expect(result["KALE"][:price]).to eq(3.00)
      expect(result["KALE"][:clearance]).to eq(false)
      expect(result["KALE"][:count]).to eq(1)
    end
  end

  describe "#apply_coupons" do
    context "base case - with perfect coupon (number of items identical):" do
      before(:each) do
        @avocado = find_item('AVOCADO')
        @avocado_coupon = coupons.find { |coupon| coupon[:item] == "AVOCADO" }
        @cart = [@avocado, @avocado]
        @consolidated_cart = consolidate_cart(@cart)
        @avocado_result = apply_coupons(@consolidated_cart, [@avocado_coupon])
      end

      it "adds a new key, value pair to the cart hash called 'ITEM NAME W/COUPON'" do
        expect(@avocado_result.keys).to include("AVOCADO W/COUPON")
      end

      it "adds the coupon price to the property hash of couponed item" do
        expect(@avocado_result["AVOCADO W/COUPON"][:price]).to eq(5.00)
      end

      it "adds the count number to the property hash of couponed item" do
        expect(@avocado_result["AVOCADO W/COUPON"][:count]).to eq(1)
      end

      it "removes the number of discounted items from the original item's count" do
        expect(@avocado_result["AVOCADO"][:price]).to eq(3.00)
        expect(@avocado_result["AVOCADO"][:count]).to eq(0)
      end

      it "remembers if the item was on clearance" do
        expect(@avocado_result["AVOCADO W/COUPON"][:clearance]).to eq(true)
      end

    end

    context "more advanced cases:" do

      it "accounts for when there are more items than the coupon allows" do
        cheese = find_item('CHEESE')
        cart = Array.new(5, cheese)
        consolidated_cart = consolidate_cart(cart)
        cheese_coupon = find_coupon("CHEESE")

        cheese_result = apply_coupons(consolidated_cart, [cheese_coupon])

        expect(cheese_result["CHEESE"][:price]).to eq(6.50)
        expect(cheese_result["CHEESE"][:count]).to eq(2)
        expect(cheese_result["CHEESE W/COUPON"][:price]).to eq(15.00)
        expect(cheese_result["CHEESE W/COUPON"][:count]).to eq(1)
        expect(cheese_result["CHEESE W/COUPON"][:clearance]).to eq(false)
      end

      it "doesn't break if the coupon doesn't apply to any items" do
        cheese = find_item('CHEESE')
        cart = Array.new(2, cheese)
        consolidated_cart = consolidate_cart(cart)

        irrelevant = apply_coupons(consolidated_cart, [find_coupon("AVOCADO")])
        expect(irrelevant["CHEESE"][:price]).to eq(6.50)
        expect(irrelevant["CHEESE"][:count]).to eq(2)
        expect(irrelevant.keys).to_not include("AVOCADO W/COUPON")
        expect(irrelevant.keys).to_not include("AVOCADO")
      end

      it "can apply multiple coupons" do
        avocado = find_item('AVOCADO')
        cheese = find_item('CHEESE')
        cart = Array.new(4, cheese)
        3.times { cart << avocado }
        consolidated_cart = consolidate_cart(cart)
        coupons = [find_coupon("AVOCADO"), find_coupon("CHEESE")]

        multiple_coupons = apply_coupons(consolidated_cart, coupons)

        ["AVOCADO", "CHEESE"].each { |item| expect(multiple_coupons[item][:count]).to eq(1) }
        expect(multiple_coupons["CHEESE"][:price]).to eq(6.50)
        expect(multiple_coupons["AVOCADO"][:price]).to eq(3.00)
        expect(multiple_coupons["CHEESE W/COUPON"][:price]).to eq(15.00)
        expect(multiple_coupons["CHEESE W/COUPON"][:count]).to eq(1)
        expect(multiple_coupons["CHEESE W/COUPON"][:clearance]).to eq(false)
        expect(multiple_coupons["AVOCADO W/COUPON"][:price]).to eq(5.00)
        expect(multiple_coupons["AVOCADO W/COUPON"][:count]).to eq(1)
        expect(multiple_coupons["AVOCADO W/COUPON"][:clearance]).to eq(true)
      end

      it "doesn't break if there is no coupon" do
        cheese = items.find { |item| item['CHEESE'] }
        cart = [cheese, cheese]
        consolidated_cart = consolidate_cart(cart)
        no_coupon_result = apply_coupons(consolidated_cart, [])
        expect(no_coupon_result["CHEESE"][:price]).to eq(6.50)
        expect(no_coupon_result["CHEESE"][:count]).to eq(2)
      end

      it "can increment coupon count if two are applied" do
        avocado = find_item("AVOCADO")
        coupon = find_coupon("AVOCADO")
        consol_cart = consolidate_cart([avocado, avocado, avocado, avocado, avocado])
        two_coupon_result = apply_coupons(consol_cart, [coupon, coupon])
        expect(two_coupon_result["AVOCADO"][:count]).to eq(1)
        expect(two_coupon_result["AVOCADO W/COUPON"][:price]).to eq(5.00)
        expect(two_coupon_result["AVOCADO"][:price]).to eq(3.00)
        expect(two_coupon_result["AVOCADO W/COUPON"][:count]).to eq(2)
      end
    end
  end

  describe "#apply_clearance" do
    it "takes 20% off price if the item is on clearance" do
      cart = [find_item('TEMPEH')]
      consolidated_cart = consolidate_cart(cart)

      result = apply_clearance(consolidated_cart)
      expect(result["TEMPEH"][:price]).to eq(2.40)
    end

    it "does not discount the price for items not on clearance" do
      cart = [find_item('AVOCADO'), find_item('TEMPEH'), find_item('BEETS'), find_item('SOY MILK')]
      consolidated_cart = consolidate_cart(cart)
      result = apply_clearance(consolidated_cart)
      clearance_prices = {"AVOCADO" => 2.40, "TEMPEH" => 2.40, "BEETS" => 2.50, "SOY MILK" => 3.60}
      result.each do |name, properties|
        expect(properties[:price]).to eq(clearance_prices[name])
      end
    end
  end

  describe "#checkout" do

    describe "base case (no clearance, no coupons)" do
      it "calls on #consolidate_cart before calculating the total for one item" do
        cart = [find_item('BEETS')]
        result = consolidate_cart(cart)

        expect(self).to receive(:consolidate_cart).with(cart).and_return(result)
        expect(checkout(cart, [])).to eq(2.50)
      end

      it "calls on #apply_coupons after calling on #consolidate_cart when there is only one item in the cart" do
        cart = [find_item('BEETS')]

        consolidated = consolidate_cart(cart)
        coupons_applied = apply_coupons(consolidated, [])

        expect(self).to receive(:consolidate_cart).with(cart).and_return(consolidated)
        expect(self).to receive(:apply_coupons).with(consolidated, []).and_return(coupons_applied)

        expect(checkout(cart, [])).to eq(2.50)
      end

      it "calls on #apply_clearance after calling on #apply_coupons when there is only one item in the cart and no coupon" do
        cart = [find_item('BEETS')]

        consolidated = consolidate_cart(cart)
        coupons_applied = apply_coupons(consolidated, [])
        clearance_applied = apply_clearance(coupons_applied)

        expect(self).to receive(:consolidate_cart).with(cart).and_return(consolidated)
        expect(self).to receive(:apply_coupons).with(consolidated, []).and_return(coupons_applied)
        expect(self).to receive(:apply_clearance).with(coupons_applied).and_return(clearance_applied)

        expect(checkout(cart, [])).to eq(2.50)
      end


      it "calls on #apply_clearance after calling on #apply_coupons with multiple items and one coupon" do
        beer = find_item('BEER')
        cart = [find_item('BEETS'), beer, beer, beer]
        coupons = [find_coupon('BEER')]

        consolidated = consolidate_cart(cart)
        coupons_applied = apply_coupons(consolidated, coupons)
        clearance_applied = apply_clearance(coupons_applied)

        expect(self).to receive(:consolidate_cart).with(cart).and_return(consolidated)
        expect(self).to receive(:apply_coupons).with(consolidated, coupons).and_return(coupons_applied)
        expect(self).to receive(:apply_clearance).with(coupons_applied).and_return(clearance_applied)

        expect(checkout(cart, coupons)).to eq(35.50)
      end

      it "calls on #apply_clearance after calling on #apply_coupons with multiple items, coupons, and items are on clearance" do
        avocado = find_item("AVOCADO")
        cheese = find_item("CHEESE")
        milk = find_item("SOY MILK")
        cart = [milk, avocado, avocado, cheese, cheese, cheese]
        coupons = [find_coupon("AVOCADO"), find_coupon("CHEESE")]

        consolidated = consolidate_cart(cart)
        coupons_applied = apply_coupons(consolidated, coupons)
        clearance_applied = apply_clearance(coupons_applied)

        expect(self).to receive(:consolidate_cart).with(cart).and_return(consolidated)
        expect(self).to receive(:apply_coupons).with(consolidated, coupons).and_return(coupons_applied)
        expect(self).to receive(:apply_clearance).with(coupons_applied).and_return(clearance_applied)

        expect(checkout(cart, coupons)).to eq(22.60)
      end

      it "calls on #consolidate_cart before calculating the total for two different items" do
        cart = [find_item('CHEESE'), find_item('BEETS')]
        result = consolidate_cart(cart)
        expect(self).to receive(:consolidate_cart).with(cart).and_return(result)
        expect(checkout(cart, [])).to eq(9.00)
      end

      it "calls on #consolidate_cart before calculating the total for two identical items" do
        beets = find_item('BEETS')
        cart = Array.new(2, beets)
        result = consolidate_cart(cart)
        expect(self).to receive(:consolidate_cart).with(cart).and_return(result)
        expect(checkout(cart, [])).to eq(5.00)
      end
    end

    describe "coupons:" do

      it "considers coupons" do
        cheese = find_item('CHEESE')
        cart = Array.new(3, cheese)
        coupons = [find_coupon("CHEESE")]
        expect(checkout(cart, coupons)).to eq(15.00)
      end

      it "considers coupons and clearance discounts" do
        avocado = find_item('AVOCADO')
        cart = Array.new(2, avocado)
        coupons = [find_coupon("AVOCADO")]
        expect(checkout(cart, coupons)).to eq(4.00)
      end

      it "charges full price for items that fall outside of coupon count" do
        beer = find_item('BEER')
        cart = Array.new(3, beer)
        coupons = [find_coupon("BEER")]
        expect(checkout(cart, coupons)).to eq(33.00)
      end

      it "only applies coupons that meet minimum amount" do
        beer = find_item('BEER')
        cart = Array.new(3, beer)
        beer_coupon = find_coupon("BEER")
        coupons = [beer_coupon, beer_coupon]
        expect(checkout(cart, coupons)).to eq(33.00)
      end
    end

    describe "clearance:" do

      it "applies a 20% discount to items on clearance" do
        cart = [find_item('PEANUTBUTTER')]
        total_cost = checkout(cart, [])
        expect(total_cost).to eq(2.40)
      end

      it "applies a 20% discount to items on clearance but not to non-clearance items" do
        cart = [find_item("BEETS"), find_item("PEANUTBUTTER")]
        total_cost = checkout(cart, [])
        expect(total_cost).to eq(4.90)
      end
    end

    describe "discount of ten percent" do
      it "applies 10% discount if cart over $100" do
        beer = find_item('BEER')
        cart = Array.new(10, beer)
        expect(checkout(cart, [])).to eq(117.00)
      end
    end
  end
end
