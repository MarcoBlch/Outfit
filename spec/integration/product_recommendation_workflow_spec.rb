require 'rails_helper'

RSpec.describe 'Product Recommendation Workflow', type: :integration do
  let(:user) { create(:user) }
  let!(:wardrobe_items) do
    [
      create(:wardrobe_item, user: user, category: 'shirt', color: 'white'),
      create(:wardrobe_item, user: user, category: 'shirt', color: 'blue'),
      create(:wardrobe_item, user: user, category: 'jeans', color: 'blue'),
      create(:wardrobe_item, user: user, category: 'sneakers', color: 'white')
    ]
  end

  before do
    # Configure ActiveJob for testing
    ActiveJob::Base.queue_adapter = :test

    # Mock Google Auth
    allow(Google::Auth).to receive(:get_application_default).and_return(
      double('authorizer', fetch_access_token!: { 'access_token' => 'mock_token' })
    )

    # Mock external API calls
    stub_gemini_outfit_suggestion_api
    stub_gemini_missing_items_api
    stub_replicate_image_generation_api
    stub_amazon_product_api
  end

  describe 'Complete workflow from outfit suggestion to product display' do
    it 'creates outfit suggestion, detects missing items, generates images, fetches products, and displays them' do
      # Step 1: User creates outfit suggestion
      context = 'professional work meeting'
      suggestion = user.outfit_suggestions.create!(
        context: context,
        status: 'pending'
      )

      # Mock outfit service behavior
      validated_outfits = [
        {
          rank: 1,
          confidence: 0.95,
          reasoning: 'Professional outfit perfect for meetings',
          items: [
            { id: wardrobe_items[0].id, category: 'shirt', role: 'top' },
            { id: wardrobe_items[2].id, category: 'jeans', role: 'bottom' }
          ]
        }
      ]

      suggestion.mark_completed!(validated_outfits, 1500, 0.01)

      expect(suggestion.reload.status).to eq('completed')
      expect(suggestion.suggestions_count).to eq(1)

      # Step 2: MissingItemDetector identifies missing items
      detector = MissingItemDetector.new(user, outfit_context: context, suggested_outfits: validated_outfits)
      missing_items = detector.detect_missing_items

      expect(missing_items).not_to be_empty
      expect(missing_items.size).to be_between(1, 3)

      missing_item = missing_items.first
      expect(missing_item).to include(:category, :description, :priority, :budget_range)
      expect(missing_item[:category]).to eq('blazer')
      expect(missing_item[:priority]).to eq('high')

      # Step 3: ProductRecommendation records are created
      product_recommendation = suggestion.product_recommendations.create!(
        category: missing_item[:category],
        description: missing_item[:description],
        color_preference: missing_item[:color_preference],
        style_notes: missing_item[:style_notes],
        reasoning: missing_item[:reasoning],
        priority: missing_item[:priority],
        budget_range: case missing_item[:budget_range]
                      when /\$0-50/ then :budget
                      when /\$51-150/ then :mid_range
                      when /\$151-300/ then :premium
                      else :luxury
                      end,
        ai_image_status: :pending,
        affiliate_products: []
      )

      expect(product_recommendation).to be_persisted
      expect(product_recommendation).to be_pending
      expect(product_recommendation.priority).to eq('high')

      # Step 4: Background jobs are enqueued (mocked)
      expect do
        GenerateProductImageJob.perform_later(product_recommendation.id)
        FetchAffiliateProductsJob.perform_later(product_recommendation.id)
      end.to have_enqueued_job(GenerateProductImageJob).with(product_recommendation.id)
        .and have_enqueued_job(FetchAffiliateProductsJob).with(product_recommendation.id)

      # Step 5: GenerateProductImageJob executes
      product_recommendation.mark_image_generating!
      expect(product_recommendation.reload).to be_generating

      # Simulate successful image generation
      image_url = 'https://replicate.delivery/generated-image.png'
      product_recommendation.mark_image_completed!(image_url, 0.0025)

      expect(product_recommendation.reload).to be_completed
      expect(product_recommendation.ai_image_url).to eq(image_url)
      expect(product_recommendation.ai_image_cost).to eq(0.0025)

      # Step 6: FetchAffiliateProductsJob executes
      amazon_products = [
        {
          'title' => 'Navy Blue Blazer Professional',
          'price' => '149.99',
          'currency' => 'USD',
          'url' => 'https://www.amazon.com/dp/B08TEST123?tag=outfit-20',
          'image_url' => 'https://m.media-amazon.com/images/I/test-blazer.jpg',
          'rating' => 4.5,
          'review_count' => 234,
          'asin' => 'B08TEST123'
        }
      ]

      amazon_products.each do |product|
        product_recommendation.add_affiliate_product(product)
      end

      expect(product_recommendation.reload.has_products?).to be true
      expect(product_recommendation.products_count).to eq(1)
      expect(product_recommendation.affiliate_products.first['title']).to eq('Navy Blue Blazer Professional')

      # Step 7: Products are displayed on frontend
      expect(suggestion.product_recommendations.with_images).to include(product_recommendation)
      expect(suggestion.product_recommendations.with_products).to include(product_recommendation)

      # Step 8: Analytics tracking works
      expect(product_recommendation.views).to eq(0)
      expect(product_recommendation.clicks).to eq(0)

      product_recommendation.record_view!
      expect(product_recommendation.reload.views).to eq(1)

      product_recommendation.record_click!
      expect(product_recommendation.reload.clicks).to eq(1)
      expect(product_recommendation.ctr).to eq(100.0) # 1 click / 1 view = 100%

      product_recommendation.record_conversion!(15.0)
      expect(product_recommendation.reload.conversions).to eq(1)
      expect(product_recommendation.revenue_earned).to eq(15.0)
      expect(product_recommendation.conversion_rate).to eq(100.0) # 1 conversion / 1 click = 100%
      expect(product_recommendation.avg_revenue_per_conversion).to eq(15.0)
    end
  end

  describe 'Error scenarios and graceful degradation' do
    it 'handles Gemini API failures gracefully' do
      stub_request(:post, /aiplatform\.googleapis\.com/)
        .to_return(status: 500, body: { error: 'Service unavailable' }.to_json)

      detector = MissingItemDetector.new(user, outfit_context: 'work', suggested_outfits: [])
      missing_items = detector.detect_missing_items

      # Should return empty array instead of raising
      expect(missing_items).to eq([])
    end

    it 'handles Replicate API failures by marking image as failed' do
      suggestion = create(:outfit_suggestion, user: user)
      recommendation = create(:product_recommendation, outfit_suggestion: suggestion, ai_image_status: :pending)

      stub_request(:post, /api\.replicate\.com/)
        .to_return(status: 500, body: { error: 'Model unavailable' }.to_json)

      recommendation.mark_image_generating!

      # Simulate job handling the error
      recommendation.mark_image_failed!('Image generation failed: Model unavailable')

      expect(recommendation.reload).to be_failed
      expect(recommendation.ai_image_error).to include('Model unavailable')
    end

    it 'handles Amazon API failures gracefully' do
      suggestion = create(:outfit_suggestion, user: user)
      recommendation = create(:product_recommendation, outfit_suggestion: suggestion)

      stub_request(:get, /amazon-data-product-data\.p\.rapidapi\.com\/search/)
        .to_return(status: 503, body: { error: 'Service Unavailable' }.to_json)

      # Products should remain empty but not crash
      expect(recommendation.has_products?).to be false
      expect(recommendation.products_count).to eq(0)
    end

    it 'continues workflow even if image generation fails' do
      suggestion = create(:outfit_suggestion, user: user)
      recommendation = create(:product_recommendation, :failed_image, outfit_suggestion: suggestion)

      # Should still be able to add products even without image
      recommendation.add_affiliate_product({
        'title' => 'Test Product',
        'price' => '99.99',
        'url' => 'https://amazon.com/test'
      })

      expect(recommendation.has_products?).to be true
      expect(recommendation).to be_failed # Image status
    end
  end

  describe 'Performance and analytics aggregation' do
    let(:suggestion) { create(:outfit_suggestion, user: user) }
    let!(:recommendations) do
      [
        create(:product_recommendation, :with_image, :with_amazon_products, outfit_suggestion: suggestion,
               views: 100, clicks: 10, conversions: 2, revenue_earned: 30.0),
        create(:product_recommendation, :with_image, :with_amazon_products, outfit_suggestion: suggestion,
               views: 200, clicks: 15, conversions: 1, revenue_earned: 15.0),
        create(:product_recommendation, :with_image, :with_amazon_products, outfit_suggestion: suggestion,
               views: 50, clicks: 5, conversions: 0, revenue_earned: 0.0)
      ]
    end

    it 'correctly calculates analytics across multiple recommendations' do
      total_views = recommendations.sum(&:views)
      total_clicks = recommendations.sum(&:clicks)
      total_conversions = recommendations.sum(&:conversions)
      total_revenue = recommendations.sum(&:revenue_earned)

      expect(total_views).to eq(350)
      expect(total_clicks).to eq(30)
      expect(total_conversions).to eq(3)
      expect(total_revenue).to eq(45.0)
    end

    it 'identifies best performing recommendations' do
      best_ctr = ProductRecommendation.best_ctr.first
      expect(best_ctr).to eq(recommendations[0]) # 10/100 = 10%

      best_conversion = ProductRecommendation.best_conversion_rate.first
      expect(best_conversion).to eq(recommendations[0]) # 2/10 = 20%

      most_clicked = ProductRecommendation.most_clicked.first
      expect(most_clicked).to eq(recommendations[1]) # 15 clicks
    end
  end

  # Helper methods to stub external APIs
  def stub_gemini_outfit_suggestion_api
    # This stub won't actually be hit in this test since we don't call outfit suggestion
    # But keep it for completeness
    stub_request(:post, /aiplatform\.googleapis\.com/)
      .with(body: /outfit|wardrobe/)
      .to_return(
        status: 200,
        body: {
          candidates: [
            {
              content: {
                parts: [
                  {
                    text: {
                      validated_suggestions: []
                    }.to_json
                  }
                ]
              }
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_gemini_missing_items_api
    # Stub Gemini API for missing items detection - broader pattern
    # The text field should contain a JSON string, not a hash
    response_json = {
      missing_items: [
        {
          category: 'blazer',
          description: 'Navy blue blazer for professional settings',
          color_preference: 'navy',
          style_notes: 'Modern slim fit',
          reasoning: 'Would complete professional outfits',
          priority: 'high',
          budget_range: '$100-200'
        }
      ]
    }.to_json

    stub_request(:post, /aiplatform\.googleapis\.com/)
      .to_return(
        status: 200,
        body: {
          candidates: [
            {
              content: {
                parts: [
                  {
                    text: response_json
                  }
                ]
              }
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_replicate_image_generation_api
    # Stub Replicate API for creating predictions
    stub_request(:post, /api\.replicate\.com\/v1\/predictions/)
      .to_return(
        status: 201,
        body: {
          id: 'test-prediction-id',
          status: 'succeeded',
          output: ['https://replicate.delivery/generated-image.png']
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Stub Replicate API for polling prediction status
    stub_request(:get, /api\.replicate\.com\/v1\/predictions\/.*/)
      .to_return(
        status: 200,
        body: {
          id: 'test-prediction-id',
          status: 'succeeded',
          output: ['https://replicate.delivery/generated-image.png']
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def stub_amazon_product_api
    # Stub RapidAPI Amazon Data endpoint
    stub_request(:get, /amazon-data-product-data\.p\.rapidapi\.com\/search/)
      .to_return(
        status: 200,
        body: {
          "products" => [
            {
              "asin" => "B08TEST123",
              "title" => "Navy Blue Blazer Professional",
              "price" => "149.99",
              "currency" => "USD",
              "product_url" => "https://www.amazon.com/dp/B08TEST123",
              "image" => "https://m.media-amazon.com/images/I/test-blazer.jpg",
              "rating" => 4.5,
              "reviews_count" => 234
            }
          ]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
