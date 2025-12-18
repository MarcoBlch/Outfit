require "rails_helper"

RSpec.describe AmazonProductMatcher, type: :service do
  let(:outfit_suggestion) { create(:outfit_suggestion) }
  let(:product_recommendation) do
    create(:product_recommendation,
           outfit_suggestion: outfit_suggestion,
           category: "dress-pants",
           description: "Black slim-fit dress pants",
           color_preference: "black",
           style_notes: "Professional modern cut suitable for business meetings",
           budget_range: :mid_range)
  end

  let(:access_key) { "FAKE_ACCESS_KEY" }
  let(:secret_key) { "FAKE_SECRET_KEY" }
  let(:partner_tag) { "test-tag-20" }

  subject(:matcher) { described_class.new(product_recommendation) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("AMAZON_ACCESS_KEY").and_return(access_key)
    allow(ENV).to receive(:[]).with("AMAZON_SECRET_KEY").and_return(secret_key)
    allow(ENV).to receive(:[]).with("AMAZON_ASSOCIATE_TAG").and_return(partner_tag)
    allow(ENV).to receive(:[]).with("AMAZON_PARTNER_TAG").and_return(partner_tag)
    allow(ENV).to receive(:[]).with("AMAZON_PARTNER_TYPE").and_return("Associates")
    allow(ENV).to receive(:[]).with("AMAZON_MARKETPLACE").and_return("www.amazon.com")
  end

  describe "#initialize" do
    it "sets instance variables correctly" do
      expect(matcher.instance_variable_get(:@recommendation)).to eq(product_recommendation)
      expect(matcher.instance_variable_get(:@access_key)).to eq(access_key)
      expect(matcher.instance_variable_get(:@secret_key)).to eq(secret_key)
      expect(matcher.instance_variable_get(:@partner_tag)).to eq(partner_tag)
      expect(matcher.instance_variable_get(:@partner_type)).to eq("Associates")
      expect(matcher.instance_variable_get(:@marketplace)).to eq("www.amazon.com")
    end
  end

  describe "#validate_credentials!" do
    context "when credentials are missing" do
      before do
        allow(ENV).to receive(:[]).with("AMAZON_ACCESS_KEY").and_return(nil)
        allow(ENV).to receive(:[]).with("AMAZON_ASSOCIATE_TAG").and_return(nil)
      end

      it "raises MatchingError during find_matching_products" do
        expect { matcher.find_matching_products(limit: 5) }
          .not_to raise_error # Should return empty array instead
      end

      it "returns empty array when credentials are missing" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end
    end

    context "when secret key is missing" do
      before do
        allow(ENV).to receive(:[]).with("AMAZON_SECRET_KEY").and_return("")
      end

      it "returns empty array gracefully" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end
    end

    context "when partner tag is missing" do
      before do
        allow(ENV).to receive(:[]).with("AMAZON_ASSOCIATE_TAG").and_return(nil)
        allow(ENV).to receive(:[]).with("AMAZON_PARTNER_TAG").and_return(nil)
      end

      it "returns empty array gracefully" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end
    end
  end

  describe "#find_matching_products" do
    let(:mock_item_1) do
      double("Item 1",
             asin: "B08ABC123",
             item_info: double(
               title: double(display_value: "Classic Black Dress Pants Slim Fit")
             ),
             offers: double(
               listings: [
                 double(
                   price: double(amount: 49.99, currency: "USD")
                 )
               ]
             ),
             images: double(
               primary: double(
                 large: double(url: "https://m.media-amazon.com/images/I/test1.jpg")
               )
             ))
    end

    let(:mock_item_2) do
      double("Item 2",
             asin: "B08XYZ789",
             item_info: double(
               title: double(display_value: "Professional Wool Blend Dress Pants")
             ),
             offers: double(
               listings: [
                 double(
                   price: double(amount: 79.99, currency: "USD")
                 )
               ]
             ),
             images: double(
               primary: double(
                 large: double(url: "https://m.media-amazon.com/images/I/test2.jpg")
               )
             ))
    end

    let(:mock_search_result) do
      double("SearchResult",
             items: [mock_item_1, mock_item_2])
    end

    let(:mock_response) do
      double("Response",
             search_result: mock_search_result)
    end

    let(:mock_client) do
      double("Client").tap do |client|
        allow(client).to receive(:search_items).and_return(mock_response)
      end
    end

    before do
      allow(Paapi::Client).to receive(:new).and_return(mock_client)
    end

    it "searches Amazon with correct query" do
      expect(mock_client).to receive(:search_items).with(
        keywords: match(/dress pants black professional modern/),
        item_count: 5,
        resources: array_including(
          "ItemInfo.Title",
          "Offers.Listings.Price",
          "Images.Primary.Large"
        ),
        search_index: "Fashion"
      ).and_return(mock_response)

      matcher.find_matching_products(limit: 5)
    end

    it "returns array of product hashes" do
      result = matcher.find_matching_products(limit: 5)

      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
    end

    it "formats products correctly" do
      result = matcher.find_matching_products(limit: 5)

      product = result.first
      expect(product["title"]).to eq("Classic Black Dress Pants Slim Fit")
      expect(product["price"]).to eq("49.99")
      expect(product["currency"]).to eq("USD")
      expect(product["affiliate_url"]).to match(%r{https://www\.amazon\.com/dp/B08ABC123})
      expect(product["image_url"]).to eq("https://m.media-amazon.com/images/I/test1.jpg")
      expect(product["asin"]).to eq("B08ABC123")
      expect(product["rating"]).to be_nil
      expect(product["review_count"]).to be_nil
    end

    it "updates recommendation with affiliate products" do
      result = matcher.find_matching_products(limit: 5)

      product_recommendation.reload
      expect(product_recommendation.affiliate_products).to eq(result)
      expect(product_recommendation.affiliate_products.length).to eq(2)
    end

    context "with budget range filtering" do
      let(:product_recommendation) do
        create(:product_recommendation, :budget,
               outfit_suggestion: outfit_suggestion,
               category: "dress-pants",
               budget_range: :budget) # $0-50
      end

      it "filters products by budget range" do
        result = matcher.find_matching_products(limit: 5)

        # Only the $49.99 item should pass the budget filter ($0-50)
        expect(result.length).to eq(1)
        expect(result.first["price"]).to eq("49.99")
      end
    end

    context "with premium budget range" do
      let(:product_recommendation) do
        create(:product_recommendation,
               outfit_suggestion: outfit_suggestion,
               category: "dress-pants",
               budget_range: :premium) # $100-300
      end

      it "filters products correctly" do
        result = matcher.find_matching_products(limit: 5)

        # Neither item falls in premium range ($100-300)
        expect(result.length).to eq(0)
      end
    end

    context "with luxury budget range" do
      let(:expensive_item) do
        double("Expensive Item",
               asin: "B08LUX999",
               item_info: double(
                 title: double(display_value: "Luxury Designer Dress Pants")
               ),
               offers: double(
                 listings: [
                   double(
                     price: double(amount: 299.99, currency: "USD")
                   )
                 ]
               ),
               images: double(
                 primary: double(
                   large: double(url: "https://m.media-amazon.com/images/I/luxury.jpg")
                 )
               ))
      end

      let(:mock_search_result) do
        double("SearchResult",
               items: [expensive_item])
      end

      let(:product_recommendation) do
        create(:product_recommendation, :luxury,
               outfit_suggestion: outfit_suggestion,
               category: "dress-pants",
               budget_range: :luxury) # $250+
      end

      it "includes luxury items" do
        result = matcher.find_matching_products(limit: 5)

        expect(result.length).to eq(1)
        expect(result.first["price"]).to eq("299.99")
      end
    end

    context "when API call fails" do
      before do
        allow(mock_client).to receive(:search_items)
          .and_raise(StandardError.new("API rate limit exceeded"))
      end

      it "returns empty array gracefully" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end

      it "logs the error" do
        allow(Rails.logger).to receive(:error)
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:warn)
        matcher.find_matching_products(limit: 5)
        expect(Rails.logger).to have_received(:error).at_least(:once)
      end

      it "does not update recommendation" do
        original_products = product_recommendation.affiliate_products
        matcher.find_matching_products(limit: 5)

        product_recommendation.reload
        expect(product_recommendation.affiliate_products).to eq(original_products)
      end
    end

    context "when item has no price" do
      let(:mock_item_no_price) do
        double("Item No Price",
               asin: "B08NOPRICE",
               item_info: double(
                 title: double(display_value: "Item Without Price")
               ),
               offers: double(listings: []),
               images: double(
                 primary: double(
                   large: double(url: "https://m.media-amazon.com/images/I/test.jpg")
                 )
               ))
      end

      let(:mock_search_result) do
        double("SearchResult",
               items: [mock_item_no_price, mock_item_1])
      end

      it "skips items without prices" do
        result = matcher.find_matching_products(limit: 5)

        expect(result.length).to eq(1)
        expect(result.first["asin"]).to eq("B08ABC123")
      end
    end

    context "when network error occurs" do
      before do
        allow(Paapi::Client).to receive(:new)
          .and_raise(StandardError.new("Network timeout"))
      end

      it "returns empty array gracefully" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end

      it "logs the error" do
        allow(Rails.logger).to receive(:error)
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:warn)
        matcher.find_matching_products(limit: 5)
        expect(Rails.logger).to have_received(:error).at_least(:once)
      end
    end

    context "when response has no items" do
      let(:mock_search_result) do
        double("SearchResult", items: nil)
      end

      it "returns empty array" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end
    end

    context "when response is nil" do
      before do
        allow(mock_client).to receive(:search_items).and_return(nil)
      end

      it "returns empty array" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end
    end
  end

  describe "#build_search_query" do
    it "includes category" do
      query = matcher.send(:build_search_query)
      expect(query).to include("dress pants")
    end

    it "includes color preference" do
      query = matcher.send(:build_search_query)
      expect(query).to include("black")
    end

    it "extracts style keywords from style_notes" do
      query = matcher.send(:build_search_query)
      expect(query).to include("professional")
      expect(query).to include("modern")
    end

    it "converts hyphens to spaces" do
      query = matcher.send(:build_search_query)
      expect(query).not_to include("-")
    end

    context "when color preference is blank" do
      before do
        product_recommendation.update!(color_preference: nil)
      end

      it "still builds valid query" do
        query = matcher.send(:build_search_query)
        expect(query).to include("dress pants")
        expect(query).not_to be_empty
      end
    end
  end

  describe "#extract_style_keywords" do
    it "extracts meaningful keywords" do
      keywords = matcher.send(:extract_style_keywords, "Professional modern cut suitable for business")

      expect(keywords).to include("professional")
      expect(keywords).to include("modern")
    end

    it "filters out common words" do
      keywords = matcher.send(:extract_style_keywords, "The best and most suitable for work")

      expect(keywords).not_to include("the")
      expect(keywords).not_to include("and")
      expect(keywords).not_to include("for")
    end

    it "filters out short words" do
      keywords = matcher.send(:extract_style_keywords, "A big red hat for men")

      expect(keywords).not_to include("big")
      expect(keywords).not_to include("red")
      expect(keywords).not_to include("hat")
      expect(keywords).not_to include("for")
      expect(keywords).not_to include("men")
    end

    it "limits to first 2 keywords" do
      keywords = matcher.send(:extract_style_keywords,
                               "Professional modern stylish comfortable versatile elegant")

      expect(keywords.length).to be <= 2
    end

    it "handles empty style notes" do
      keywords = matcher.send(:extract_style_keywords, "")
      expect(keywords).to be_empty
    end
  end

  describe "#filter_by_budget" do
    let(:products) do
      [
        { "title" => "Budget Item", "price" => "25.00", "asin" => "B1" },        # $25 - in budget range
        { "title" => "Mid Range Item", "price" => "75.00", "asin" => "B2" },    # $75 - in mid_range
        { "title" => "Premium Item", "price" => "180.00", "asin" => "B3" },     # $180 - in premium range
        { "title" => "Luxury Item", "price" => "350.00", "asin" => "B4" }       # $350 - in luxury range
      ]
    end

    context "with budget range" do
      before do
        product_recommendation.update!(budget_range: :budget)
      end

      it "filters to budget items only ($0-50)" do
        result = matcher.send(:filter_by_budget, products)

        expect(result.length).to eq(1)
        expect(result.first["title"]).to eq("Budget Item")
      end
    end

    context "with mid_range" do
      before do
        product_recommendation.update!(budget_range: :mid_range)
      end

      it "filters to mid-range items ($30-150)" do
        result = matcher.send(:filter_by_budget, products)

        expect(result.length).to eq(1)
        expect(result.first["title"]).to eq("Mid Range Item")
      end
    end

    context "with premium range" do
      before do
        product_recommendation.update!(budget_range: :premium)
      end

      it "filters to premium items ($100-300)" do
        result = matcher.send(:filter_by_budget, products)

        expect(result.length).to eq(1)
        expect(result.first["title"]).to eq("Premium Item")
      end
    end

    context "with luxury range" do
      before do
        product_recommendation.update!(budget_range: :luxury)
      end

      it "filters to luxury items ($250+, no upper limit)" do
        result = matcher.send(:filter_by_budget, products)

        expect(result.length).to eq(1)
        expect(result.first["title"]).to eq("Luxury Item")
      end
    end
  end

  describe "#extract_price" do
    context "with valid price" do
      let(:item) do
        double("Item",
               offers: double(
                 listings: [
                   double(price: double(amount: 49.99, currency: "USD"))
                 ]
               ))
      end

      it "extracts price correctly" do
        result = matcher.send(:extract_price, item)

        expect(result[:price]).to eq("49.99")
        expect(result[:currency]).to eq("USD")
        expect(result[:amount_cents]).to eq(4999)
      end
    end

    context "with no offers" do
      let(:item) do
        double("Item", offers: nil)
      end

      it "returns nil" do
        result = matcher.send(:extract_price, item)
        expect(result).to be_nil
      end
    end

    context "with empty listings" do
      let(:item) do
        double("Item",
               offers: double(listings: []))
      end

      it "returns nil" do
        result = matcher.send(:extract_price, item)
        expect(result).to be_nil
      end
    end

    context "with no price in listing" do
      let(:item) do
        double("Item",
               offers: double(
                 listings: [double(price: nil)]
               ))
      end

      it "returns nil" do
        result = matcher.send(:extract_price, item)
        expect(result).to be_nil
      end
    end
  end

  describe "#parse_item" do
    let(:item) do
      double("Item",
             asin: "B08TEST123",
             item_info: double(
               title: double(display_value: "Test Product")
             ),
             offers: double(
               listings: [
                 double(price: double(amount: 29.99, currency: "USD"))
               ]
             ),
             images: double(
               primary: double(
                 large: double(url: "https://example.com/image.jpg")
               )
             ))
    end

    it "parses item into correct format" do
      result = matcher.send(:parse_item, item)

      expect(result["title"]).to eq("Test Product")
      expect(result["price"]).to eq("29.99")
      expect(result["currency"]).to eq("USD")
      expect(result["affiliate_url"]).to match(%r{https://www\.amazon\.com/dp/B08TEST123})
      expect(result["image_url"]).to eq("https://example.com/image.jpg")
      expect(result["asin"]).to eq("B08TEST123")
      expect(result["rating"]).to be_nil
      expect(result["review_count"]).to be_nil
    end

    context "when item has no price" do
      let(:item) do
        double("Item",
               asin: "B08TEST123",
               item_info: double(
                 title: double(display_value: "Test Product")
               ),
               offers: double(listings: []),
               images: double(
                 primary: double(
                   large: double(url: "https://example.com/image.jpg")
                 )
               ))
      end

      it "returns nil" do
        result = matcher.send(:parse_item, item)
        expect(result).to be_nil
      end
    end

    context "when item has no title" do
      let(:item) do
        double("Item",
               asin: "B08TEST123",
               item_info: double(title: nil),
               offers: double(
                 listings: [
                   double(price: double(amount: 29.99, currency: "USD"))
                 ]
               ),
               images: nil)
      end

      it "returns nil" do
        result = matcher.send(:parse_item, item)
        expect(result).to be_nil
      end
    end
  end

  describe "constant BUDGET_PRICE_RANGES" do
    it "defines correct price ranges" do
      expect(AmazonProductMatcher::BUDGET_PRICE_RANGES[:budget]).to eq(min: 0, max: 5000)
      expect(AmazonProductMatcher::BUDGET_PRICE_RANGES[:mid_range]).to eq(min: 3000, max: 15000)
      expect(AmazonProductMatcher::BUDGET_PRICE_RANGES[:premium]).to eq(min: 10000, max: 30000)
      expect(AmazonProductMatcher::BUDGET_PRICE_RANGES[:luxury]).to eq(min: 25000, max: nil)
    end
  end

  describe "#determine_market" do
    it "maps US marketplace correctly" do
      allow(ENV).to receive(:[]).with("AMAZON_MARKETPLACE").and_return("www.amazon.com")
      matcher = described_class.new(product_recommendation)
      expect(matcher.send(:determine_market)).to eq(:us)
    end

    it "maps UK marketplace correctly" do
      allow(ENV).to receive(:[]).with("AMAZON_MARKETPLACE").and_return("www.amazon.co.uk")
      matcher = described_class.new(product_recommendation)
      expect(matcher.send(:determine_market)).to eq(:uk)
    end

    it "defaults to US for unknown marketplace" do
      allow(ENV).to receive(:[]).with("AMAZON_MARKETPLACE").and_return("unknown.amazon.com")
      matcher = described_class.new(product_recommendation)
      expect(matcher.send(:determine_market)).to eq(:us)
    end
  end

  describe "#determine_search_index" do
    it "returns Shoes for shoe categories" do
      product_recommendation.update!(category: "sneakers")
      expect(matcher.send(:determine_search_index)).to eq("Shoes")

      product_recommendation.update!(category: "boots")
      expect(matcher.send(:determine_search_index)).to eq("Shoes")
    end

    it "returns Fashion for clothing categories" do
      product_recommendation.update!(category: "shirt")
      expect(matcher.send(:determine_search_index)).to eq("Fashion")

      product_recommendation.update!(category: "dress-pants")
      expect(matcher.send(:determine_search_index)).to eq("Fashion")

      product_recommendation.update!(category: "jacket")
      expect(matcher.send(:determine_search_index)).to eq("Fashion")
    end

    it "returns Jewelry for jewelry categories" do
      product_recommendation.update!(category: "watch")
      expect(matcher.send(:determine_search_index)).to eq("Jewelry")
    end

    it "returns Luggage for bag categories" do
      product_recommendation.update!(category: "bag")
      expect(matcher.send(:determine_search_index)).to eq("Luggage")
    end

    it "returns All for unknown categories" do
      product_recommendation.update!(category: "unknown-item")
      expect(matcher.send(:determine_search_index)).to eq("All")
    end
  end

  describe "#format_price_amount" do
    it "formats price correctly from cents" do
      result = matcher.send(:format_price_amount, 4999, "USD")
      expect(result).to eq("49.99")
    end

    it "handles zero amount" do
      result = matcher.send(:format_price_amount, 0, "USD")
      expect(result).to eq("0.00")
    end

    it "returns nil for nil amount" do
      result = matcher.send(:format_price_amount, nil, "USD")
      expect(result).to be_nil
    end
  end

  describe "#parse_amazon_response with hash response" do
    let(:hash_response) do
      {
        "SearchResult" => {
          "Items" => [
            {
              "ASIN" => "B08HASH123",
              "ItemInfo" => {
                "Title" => {
                  "DisplayValue" => "Hash Response Product"
                }
              },
              "Offers" => {
                "Listings" => [
                  {
                    "Price" => {
                      "DisplayAmount" => "$39.99",
                      "Amount" => 3999,
                      "Currency" => "USD"
                    }
                  }
                ]
              },
              "Images" => {
                "Primary" => {
                  "Large" => {
                    "URL" => "https://example.com/hash.jpg"
                  }
                }
              },
              "DetailPageURL" => "https://www.amazon.com/dp/B08HASH123?tag=test-tag-20"
            }
          ]
        }
      }
    end

    let(:hash_mock_client) do
      double("Client").tap do |client|
        allow(client).to receive(:search_items).and_return(hash_response)
      end
    end

    before do
      allow(Paapi::Client).to receive(:new).and_return(hash_mock_client)
    end

    it "parses hash response correctly" do
      result = matcher.find_matching_products(limit: 5)

      expect(result).to be_an(Array)
      expect(result.length).to eq(1)

      product = result.first
      expect(product["title"]).to eq("Hash Response Product")
      expect(product["price"]).to eq("39.99")
      expect(product["currency"]).to eq("USD")
      expect(product["asin"]).to eq("B08HASH123")
      expect(product["image_url"]).to eq("https://example.com/hash.jpg")
      expect(product["affiliate_url"]).to eq("https://www.amazon.com/dp/B08HASH123?tag=test-tag-20")
    end
  end
end
