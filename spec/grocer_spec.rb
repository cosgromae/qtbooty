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
      tempeh = items.find { |item| item['TEMPEH'] }
      butter = items.find { |item| item['PEANUTBUTTER'] }
      almonds = items.find { |item| item['ALMONDS'] }
      cart = [tempeh, butter, almonds]

      result = consolidate_cart(cart: cart)
      result.each do |item, attributes|
        expect(attributes.keys).to include(:count)
        expect(attributes[:count]).to eq(1)
      end
    end

    it "increments count when there are multiple items" do
      # items comes from the rspec "let" above.
      avocado = items.find { |item| item['AVOCADO'] }
      kale = items.find { |item| item['KALE'] }
      cart = [avocado, avocado, kale]

      result = consolidate_cart(cart: cart)

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
        avocado = items.find { |item| item['AVOCADO'] }
        avocado_coupon = coupons.find { |coupon| coupon[:item] == "AVOCADO" }
        cart = [avocado, avocado]
        consolidated_cart = consolidate_cart(cart: cart)
        @avocado_result = apply_coupons(cart: consolidated_cart, coupons: [avocado_coupon])
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
        cheese = items.find { |item| item['CHEESE'] }
        cart = [cheese, cheese, cheese, cheese, cheese]
        consolidated_cart = consolidate_cart(cart: cart)
        cheese_coupon = coupons.find { |coupon| coupon[:item] == "CHEESE" }

        cheese_result = apply_coupons(cart: consolidated_cart, coupons: [cheese_coupon])
        
        expect(cheese_result["CHEESE"][:price]).to eq(6.50)
        expect(cheese_result["CHEESE"][:count]).to eq(2)
        expect(cheese_result["CHEESE W/COUPON"][:price]).to eq(15.00)
        expect(cheese_result["CHEESE W/COUPON"][:count]).to eq(1)
        expect(cheese_result["CHEESE W/COUPON"][:clearance]).to eq(false)
      end

      it "doesn't break if the coupon doesn't apply to any items" do 
        cheese = items.find { |item| item['CHEESE'] }
        cart = [cheese, cheese]
        consolidated_cart = consolidate_cart(cart: cart)
        avocado_coupon = coupons.find { |coupon| coupon[:item] == "AVOCADO" }

        irrelevant_coupon_result = apply_coupons(cart: consolidated_cart, coupons: [avocado_coupon])
        expect(irrelevant_coupon_result["CHEESE"][:price]).to eq(6.50)
        expect(irrelevant_coupon_result["CHEESE"][:count]).to eq(2)  
        expect(irrelevant_coupon_result.keys).to_not include("AVOCADO W/COUPON")
        expect(irrelevant_coupon_result.keys).to_not include("AVOCADO")
      end

      it "can apply multiple coupons" do
        avocado = items.find { |item| item['AVOCADO'] }
        cheese = items.find { |item| item['CHEESE'] }
        cart = [cheese, cheese, cheese, cheese, avocado, avocado, avocado]
        consolidated_cart = consolidate_cart(cart: cart)
        avocado_coupon = coupons.find { |coupon| coupon[:item] == "AVOCADO" }
        cheese_coupon = coupons.find { |coupon| coupon[:item] == "CHEESE" }
        coupons = [avocado_coupon, cheese_coupon]

        multiple_coupons = apply_coupons(cart: consolidated_cart, coupons: coupons)

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
        consolidated_cart = consolidate_cart(cart: cart)
        no_coupon_result = apply_coupons(cart: consolidated_cart, coupons: [])
        expect(no_coupon_result["CHEESE"][:price]).to eq(6.50)
        expect(no_coupon_result["CHEESE"][:count]).to eq(2)  
      end
    end
  end

  describe "#apply_clearance" do
    it "takes 20% off price if the item is on clearance" do
      tempeh = items.find { |item| item['TEMPEH'] }
      cart = [tempeh]
      consolidated_cart = consolidate_cart(cart: cart)

      result = apply_clearance(cart: consolidated_cart)
      expect(result["TEMPEH"][:price]).to eq(2.40)
    end

    it "does not discount the price for items not on clearance" do
      avocado = items.find { |item| item['AVOCADO'] }
      tempeh = items.find { |item| item['TEMPEH'] }
      beets = items.find { |item| item['BEETS'] }
      milk = items.find { |item| item['SOY MILK'] }
      cart = [avocado, tempeh, beets, milk]
      consolidated_cart = consolidate_cart(cart: cart)

      result = apply_clearance(cart: consolidated_cart)
      clearance_prices = {"AVOCADO" => 2.40, "TEMPEH" => 2.40, "BEETS" => 2.50, "SOY MILK" => 3.60}
      result.each do |name, properties|
        expect(properties[:price]).to eq(clearance_prices[name])
      end
    end
  end
  
  describe "#checkout" do

    describe "base case (no clearance, no coupons)" do 
      it "calls on #consolidate_cart before calculating the total for one item" do
        beets = items.find { |item| item['BEETS'] }
        cart = [beets]
        result = consolidate_cart(cart: cart)

        expect(self).to receive(:consolidate_cart).with(cart: cart).and_return(result)
        expect(checkout(cart: cart, coupons: [])).to eq(2.50)
      end

      it "calls on #consolidate_cart before calculating the total for two different items" do
        beets = items.find { |item| item['BEETS'] }
        cheese = items.find { |item| item['CHEESE'] }
        cart = [beets, cheese]
        result = consolidate_cart(cart: cart)
        expect(self).to receive(:consolidate_cart).with(cart: cart).and_return(result)
        expect(checkout(cart: cart, coupons: [])).to eq(9.00)
      end

      it "calls on #consolidate_cart before calculating the total for two identical items" do
        beets = items.find { |item| item['BEETS'] }
        cart = [beets, beets]
        result = consolidate_cart(cart: cart)
        expect(self).to receive(:consolidate_cart).with(cart: cart).and_return(result)
        expect(checkout(cart: cart, coupons: [])).to eq(5.00)
      end
    end    

    describe "clearance" do
      it "applies a 20% discount to items on clearance" do
        # Clearance item
        pb = items.find { |item| item['PEANUTBUTTER'] }
        cart = [pb]
        total_cost = checkout(cart: cart, coupons: [])
        expect(total_cost).to eq(2.40)
      end

      it "applies a 20% discount to items on clearance but not to non-clearance items" do
        # Clearance item
        beets = items.find { |item| item['BEETS'] }
        pb = items.find { |item| item['PEANUTBUTTER'] }
        cart = [pb, beets]

        total_cost = checkout(cart: cart, coupons: [])
        expect(total_cost).to eq(4.90)
      end
    end

    describe "coupons:" do
      it "considers coupons" do
        cheese = items.find { |item| item['CHEESE'] }
        cart = [cheese, cheese, cheese]

        cheese_coupon = coupons.find { |coupon| coupon[:item] == "CHEESE" }
        coupons = [cheese_coupon]

        expect(checkout(cart: cart, coupons: coupons)).to eq(15.00)
      end

      it "considers coupons and clearance discounts" do
        avocado = items.find { |item| item['AVOCADO'] }
        cart = [avocado, avocado]

        avocado_coupon = coupons.find { |coupon| coupon[:item] == "AVOCADO" }
        coupons = [avocado_coupon]

        expect(checkout(cart: cart, coupons: coupons)).to eq(4.00)
      end

      it "charges full price for items that fall outside of coupon count" do
        beer = items.find { |item| item['BEER'] }
        cart = [beer, beer, beer]

        beer_coupon = coupons.find { |coupon| coupon[:item] == "BEER" }
        coupons = [beer_coupon]

        expect(checkout(cart: cart, coupons: coupons)).to eq(33.00)
      end

      it "only applies coupons that meet minimum amount" do
        beer = items.find { |item| item['BEER'] }
        cart = [beer, beer, beer]

        beer_coupon = coupons.find { |coupon| coupon[:item] == "BEER" }
        coupons = [beer_coupon, beer_coupon]

        expect(checkout(cart: cart, coupons: coupons)).to eq(33.00)
      end
    end

    describe "discount of ten percent" do
      it "applies 10% discount if cart over $100" do
        beer = items.find { |item| item['BEER'] }
        cart = []

        10.times { cart << beer }

        expect(checkout(cart: cart, coupons: [])).to eq(117.00)
      end
    end
  end
end
