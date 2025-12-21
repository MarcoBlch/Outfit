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

  let(:rapidapi_key) { "test_rapidapi_key_123" }
  let(:rapidapi_host) { "real-time-amazon-data.p.rapidapi.com" }
  let(:partner_tag) { "outfitmaker0d-20" }

  subject(:matcher) { described_class.new(product_recommendation) }

  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("RAPIDAPI_KEY").and_return(rapidapi_key)
    allow(ENV).to receive(:[]).with("RAPIDAPI_HOST").and_return(rapidapi_host)
    allow(ENV).to receive(:[]).with("AMAZON_ASSOCIATE_TAG").and_return(partner_tag)
    allow(ENV).to receive(:[]).with("AMAZON_PARTNER_TAG").and_return(partner_tag)
    allow(ENV).to receive(:[]).with("AMAZON_MARKETPLACE").and_return("US")
  end

  describe "#initialize" do
    it "sets instance variables correctly" do
      expect(matcher.instance_variable_get(:@recommendation)).to eq(product_recommendation)
      expect(matcher.instance_variable_get(:@rapidapi_key)).to eq(rapidapi_key)
      expect(matcher.instance_variable_get(:@rapidapi_host)).to eq(rapidapi_host)
      expect(matcher.instance_variable_get(:@partner_tag)).to eq(partner_tag)
      expect(matcher.instance_variable_get(:@marketplace)).to eq("US")
    end
  end

  describe "#validate_credentials!" do
    context "when credentials are missing" do
      before do
        allow(ENV).to receive(:[]).with("RAPIDAPI_KEY").and_return(nil)
        allow(ENV).to receive(:[]).with("AMAZON_ASSOCIATE_TAG").and_return(nil)
      end

      it "returns empty array gracefully" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end
    end

    context "when RapidAPI key is missing" do
      before do
        allow(ENV).to receive(:[]).with("RAPIDAPI_KEY").and_return("")
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
    let(:rapidapi_response) do
      {
        "products" => [
          {
            "asin" => "B08ABC123",
            "title" => "Classic Black Dress Pants Slim Fit",
            "price" => "49.99",
            "currency" => "USD",
            "image" => "https://m.media-amazon.com/images/I/test1.jpg",
            "product_url" => "https://www.amazon.com/dp/B08ABC123",
            "rating" => 4.5,
            "reviews_count" => 234
          },
          {
            "asin" => "B08XYZ789",
            "title" => "Professional Wool Blend Dress Pants",
            "price" => "79.99",
            "currency" => "USD",
            "image" => "https://m.media-amazon.com/images/I/test2.jpg",
            "product_url" => "https://www.amazon.com/dp/B08XYZ789",
            "rating" => 4.7,
            "reviews_count" => 567
          }
        ]
      }.to_json
    end

    before do
      stub_request(:get, /real-time-amazon-data\.p\.rapidapi\.com\/search/)
        .with(
          headers: {
            'X-RapidAPI-Key' => rapidapi_key,
            'X-RapidAPI-Host' => rapidapi_host
          }
        )
        .to_return(status: 200, body: rapidapi_response, headers: { 'Content-Type' => 'application/json' })
    end

    it "makes request to RapidAPI with correct headers" do
      matcher.find_matching_products(limit: 5)

      expect(WebMock).to have_requested(:get, /real-time-amazon-data\.p\.rapidapi\.com\/search/)
        .with(
          headers: {
            'X-RapidAPI-Key' => rapidapi_key,
            'X-RapidAPI-Host' => rapidapi_host
          }
        ).once
    end

    it "builds correct search query from recommendation" do
      matcher.find_matching_products(limit: 5)

      expect(WebMock).to have_requested(:get, /real-time-amazon-data\.p\.rapidapi\.com\/search/)
        .with(query: hash_including({
          'query' => match(/dress pants black/i),
          'country' => 'US'
        }))
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
      expect(product["affiliate_url"]).to include("tag=#{partner_tag}")
      expect(product["image_url"]).to eq("https://m.media-amazon.com/images/I/test1.jpg")
      expect(product["asin"]).to eq("B08ABC123")
      expect(product["rating"]).to eq(4.5)
      expect(product["review_count"]).to eq(234)
    end

    it "adds affiliate tag to product URLs" do
      result = matcher.find_matching_products(limit: 5)

      result.each do |product|
        expect(product["affiliate_url"]).to include("tag=#{partner_tag}")
      end
    end

    it "updates recommendation with affiliate products" do
      result = matcher.find_matching_products(limit: 5)

      product_recommendation.reload
      expect(product_recommendation.affiliate_products).to eq(result)
      expect(product_recommendation.affiliate_products.length).to eq(2)
    end

    context "with budget range filtering" do
      let(:product_recommendation) do
        create(:product_recommendation,
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

    context "with mid_range budget" do
      let(:product_recommendation) do
        create(:product_recommendation,
               outfit_suggestion: outfit_suggestion,
               category: "dress-pants",
               budget_range: :mid_range) # $30-150
      end

      it "includes both items in mid-range" do
        result = matcher.find_matching_products(limit: 5)

        # Both $49.99 and $79.99 are in mid-range ($30-150)
        expect(result.length).to eq(2)
      end
    end

    context "with premium budget range" do
      let(:rapidapi_response) do
        {
          "products" => [
            {
              "asin" => "B08LUX999",
              "title" => "Luxury Designer Dress Pants",
              "price" => "199.99",
              "currency" => "USD",
              "image" => "https://m.media-amazon.com/images/I/luxury.jpg",
              "product_url" => "https://www.amazon.com/dp/B08LUX999"
            }
          ]
        }.to_json
      end

      let(:product_recommendation) do
        create(:product_recommendation,
               outfit_suggestion: outfit_suggestion,
               category: "dress-pants",
               budget_range: :premium) # $100-300
      end

      it "includes premium items" do
        result = matcher.find_matching_products(limit: 5)

        expect(result.length).to eq(1)
        expect(result.first["price"]).to eq("199.99")
      end
    end

    context "with luxury budget range" do
      let(:rapidapi_response) do
        {
          "products" => [
            {
              "asin" => "B08LUX999",
              "title" => "Luxury Designer Dress Pants",
              "price" => "299.99",
              "currency" => "USD",
              "image" => "https://m.media-amazon.com/images/I/luxury.jpg",
              "product_url" => "https://www.amazon.com/dp/B08LUX999"
            }
          ]
        }.to_json
      end

      let(:product_recommendation) do
        create(:product_recommendation,
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
        stub_request(:get, /real-time-amazon-data\.p\.rapidapi\.com\/search/)
          .to_return(status: 500, body: { error: "Service unavailable" }.to_json)
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

    context "when API times out" do
      before do
        stub_request(:get, /real-time-amazon-data\.p\.rapidapi\.com\/search/)
          .to_timeout
      end

      it "returns empty array gracefully" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to eq([])
      end
    end

    context "when item has no price" do
      let(:rapidapi_response) do
        {
          "products" => [
            {
              "asin" => "B08NOPRICE",
              "title" => "Item Without Price",
              "image" => "https://m.media-amazon.com/images/I/noprice.jpg",
              "product_url" => "https://www.amazon.com/dp/B08NOPRICE"
            }
          ]
        }.to_json
      end

      it "skips items without prices" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to be_empty
      end
    end

    context "with price as DisplayAmount format" do
      let(:rapidapi_response) do
        {
          "products" => [
            {
              "asin" => "B08TEST",
              "title" => "Test Product",
              "price" => "$39.99",
              "currency" => "USD",
              "image" => "https://m.media-amazon.com/images/I/test.jpg",
              "product_url" => "https://www.amazon.com/dp/B08TEST"
            }
          ]
        }.to_json
      end

      it "parses price with currency symbol" do
        result = matcher.find_matching_products(limit: 5)

        expect(result.length).to eq(1)
        expect(result.first["price"]).to eq("39.99")
      end
    end

    context "with different response field names" do
      let(:rapidapi_response) do
        {
          "results" => [
            {
              "ASIN" => "B08DIFF",
              "product_title" => "Different Field Names",
              "product_price" => 59.99,
              "image_url" => "https://m.media-amazon.com/images/I/diff.jpg",
              "url" => "https://www.amazon.com/dp/B08DIFF"
            }
          ]
        }.to_json
      end

      it "handles alternative field names" do
        result = matcher.find_matching_products(limit: 5)

        expect(result.length).to eq(1)
        product = result.first
        expect(product["asin"]).to eq("B08DIFF")
        expect(product["title"]).to eq("Different Field Names")
        expect(product["price"]).to eq("59.99")
      end
    end

    context "with empty API response" do
      let(:rapidapi_response) do
        { "products" => [] }.to_json
      end

      it "returns empty array" do
        result = matcher.find_matching_products(limit: 5)
        expect(result).to be_empty
      end

      it "logs warning" do
        allow(Rails.logger).to receive(:warn)
        allow(Rails.logger).to receive(:info)

        matcher.find_matching_products(limit: 5)
        expect(Rails.logger).to have_received(:warn).with(/No products found/)
      end
    end
  end

  describe "#build_search_query" do
    it "combines category and color preference" do
      query = matcher.send(:build_search_query)
      expect(query).to include("dress pants")
      expect(query).to include("black")
    end

    it "includes style keywords" do
      query = matcher.send(:build_search_query)
      expect(query).to match(/professional|modern/)
    end

    it "handles missing fields gracefully" do
      rec = create(:product_recommendation,
                   outfit_suggestion: outfit_suggestion,
                   category: "blazer",
                   color_preference: nil,
                   style_notes: nil)

      matcher = described_class.new(rec)
      query = matcher.send(:build_search_query)

      expect(query).to eq("blazer")
    end
  end

  describe "#determine_category_id" do
    it "maps shoe categories correctly" do
      rec = create(:product_recommendation, outfit_suggestion: outfit_suggestion, category: "sneakers")
      matcher = described_class.new(rec)

      category = matcher.send(:determine_category_id)
      expect(category).to eq("fashion-shoes")
    end

    it "maps clothing categories correctly" do
      rec = create(:product_recommendation, outfit_suggestion: outfit_suggestion, category: "blazer")
      matcher = described_class.new(rec)

      category = matcher.send(:determine_category_id)
      expect(category).to eq("fashion-clothing")
    end

    it "maps jewelry categories correctly" do
      rec = create(:product_recommendation, outfit_suggestion: outfit_suggestion, category: "watch")
      matcher = described_class.new(rec)

      category = matcher.send(:determine_category_id)
      expect(category).to eq("fashion-jewelry")
    end

    it "maps bag categories correctly" do
      rec = create(:product_recommendation, outfit_suggestion: outfit_suggestion, category: "handbag")
      matcher = described_class.new(rec)

      category = matcher.send(:determine_category_id)
      expect(category).to eq("fashion-bags")
    end

    it "defaults to fashion for unknown categories" do
      rec = create(:product_recommendation, outfit_suggestion: outfit_suggestion, category: "unknown-item")
      matcher = described_class.new(rec)

      category = matcher.send(:determine_category_id)
      expect(category).to eq("fashion")
    end
  end
end
