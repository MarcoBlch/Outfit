require "rails_helper"

RSpec.describe MissingItemDetector, type: :service do
  let(:user) { create(:user) }
  let(:user_profile) do
    create(:user_profile,
           user: user,
           presentation_style: :masculine,
           style_preference: :business_casual,
           body_type: :athletic,
           age_range: "25-34",
           metadata: { "favorite_colors" => ["navy", "gray", "white"] })
  end
  let(:outfit_context) { "Job interview at a tech startup" }
  let(:suggested_outfits) { [] }

  subject(:detector) do
    described_class.new(user,
                       outfit_context: outfit_context,
                       suggested_outfits: suggested_outfits)
  end

  before do
    # Set required environment variables
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOOGLE_CLOUD_PROJECT').and_return('test-project')
    allow(ENV).to receive(:[]).with('GOOGLE_CLOUD_LOCATION').and_return('us-central1')

    # Stub Google Auth to prevent real OAuth2 calls
    allow(Google::Auth).to receive(:get_application_default).and_return(
      double(fetch_access_token!: { 'access_token' => 'test-token' })
    )

    # Setup basic wardrobe
    create(:wardrobe_item, user: user, category: "t-shirt", color: "blue")
    create(:wardrobe_item, user: user, category: "jeans", color: "blue")
    create(:wardrobe_item, user: user, category: "sneakers", color: "white")
  end

  describe "#initialize" do
    it "sets instance variables correctly" do
      expect(detector.instance_variable_get(:@user)).to eq(user)
      expect(detector.instance_variable_get(:@outfit_context)).to eq(outfit_context)
      expect(detector.instance_variable_get(:@suggested_outfits)).to eq(suggested_outfits)
    end

    it "configures Google Cloud AI endpoint" do
      endpoint = detector.instance_variable_get(:@api_endpoint)
      expect(endpoint).to include("aiplatform.googleapis.com")
      expect(endpoint).to include("gemini-2.5-flash")
    end
  end

  describe "#detect_missing_items" do
    context "when API call succeeds" do
      it "returns parsed missing items" do
        mock_response = {
          "missing_items" => [
            {
              "category" => "blazer",
              "description" => "Navy blue blazer in wool-blend fabric",
              "color_preference" => "navy",
              "style_notes" => "Professional yet modern, suitable for tech interviews",
              "reasoning" => "Would complete professional outfits with existing casual items",
              "priority" => "high",
              "budget_range" => "$100-200"
            },
            {
              "category" => "dress-shoes",
              "description" => "Brown leather loafers or oxfords",
              "color_preference" => "brown",
              "style_notes" => "Versatile formal footwear",
              "reasoning" => "Sneakers insufficient for interview context",
              "priority" => "high",
              "budget_range" => "$80-150"
            }
          ]
        }

        gemini_api_response = {
          'candidates' => [
            {
              'content' => {
                'parts' => [
                  {
                    'text' => mock_response.to_json
                  }
                ]
              }
            }
          ]
        }

        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_return(
            status: 200,
            body: gemini_api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = detector.detect_missing_items

        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result.first[:category]).to eq("blazer")
        expect(result.first[:priority]).to eq("high")
      end

      it "sorts items by priority" do
        priority_response = {
          "missing_items" => [
            {
              "category" => "belt",
              "description" => "Leather belt",
              "priority" => "low"
            },
            {
              "category" => "blazer",
              "description" => "Navy blazer",
              "priority" => "high"
            },
            {
              "category" => "shirt",
              "description" => "Dress shirt",
              "priority" => "medium"
            }
          ]
        }

        priority_api_response = {
          'candidates' => [
            {
              'content' => {
                'parts' => [
                  {
                    'text' => priority_response.to_json
                  }
                ]
              }
            }
          ]
        }

        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_return(
            status: 200,
            body: priority_api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = detector.detect_missing_items

        expect(result[0][:priority]).to eq("high")
        expect(result[1][:priority]).to eq("medium")
        expect(result[2][:priority]).to eq("low")
      end

      it "validates priority values" do
        invalid_priority_response = {
          "missing_items" => [
            {
              "category" => "blazer",
              "description" => "Navy blazer",
              "priority" => "INVALID"
            }
          ]
        }

        invalid_priority_api_response = {
          'candidates' => [
            {
              'content' => {
                'parts' => [
                  {
                    'text' => invalid_priority_response.to_json
                  }
                ]
              }
            }
          ]
        }

        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_return(
            status: 200,
            body: invalid_priority_api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = detector.detect_missing_items

        expect(result.first[:priority]).to eq("medium") # Defaults to medium
      end
    end

    context "when API returns empty suggestions" do
      it "returns empty array" do
        empty_response = { "missing_items" => [] }
        empty_api_response = {
          'candidates' => [
            {
              'content' => {
                'parts' => [
                  {
                    'text' => empty_response.to_json
                  }
                ]
              }
            }
          ]
        }

        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_return(
            status: 200,
            body: empty_api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = detector.detect_missing_items
        expect(result).to eq([])
      end
    end

    context "when API returns invalid data" do
      it "returns empty array" do
        invalid_response = { "missing_items" => nil }
        invalid_api_response = {
          'candidates' => [
            {
              'content' => {
                'parts' => [
                  {
                    'text' => invalid_response.to_json
                  }
                ]
              }
            }
          ]
        }

        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_return(
            status: 200,
            body: invalid_api_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = detector.detect_missing_items
        expect(result).to eq([])
      end
    end

    context "when API call fails" do
      it "returns empty array gracefully" do
        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_return(status: 500, body: '{"error": "Internal Server Error"}', headers: { 'Content-Type' => 'application/json' })

        result = detector.detect_missing_items
        expect(result).to eq([])
      end

      it "logs the error" do
        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_return(status: 500, body: '{"error": "Internal Server Error"}', headers: { 'Content-Type' => 'application/json' })

        allow(Rails.logger).to receive(:error)
        detector.detect_missing_items
        expect(Rails.logger).to have_received(:error).with(/Missing Item Detection Failed/)
      end
    end

    context "when network error occurs" do
      it "returns empty array gracefully" do
        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_timeout

        result = detector.detect_missing_items
        expect(result).to eq([])
      end
    end
  end

  describe "#build_detection_prompt" do
    before do
      user_profile # Ensure profile exists

      # Stub HTTP for these tests (they don't actually call the API)
      stub_request(:post, %r{https://.*aiplatform\.googleapis\.com/.*})
        .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
    end

    it "includes user profile information" do
      prompt = detector.send(:build_detection_prompt)

      expect(prompt).to include("USER PROFILE")
      expect(prompt).to include("masculine")
      expect(prompt).to include("business_casual")
      expect(prompt).to include("25-34")
      expect(prompt).to include("navy, gray, white")
    end

    it "includes outfit context" do
      prompt = detector.send(:build_detection_prompt)
      expect(prompt).to include("Job interview at a tech startup")
    end

    it "includes wardrobe summary" do
      prompt = detector.send(:build_detection_prompt)
      expect(prompt).to include("CURRENT WARDROBE SUMMARY")
      expect(prompt).to include("3 items")
    end

    context "with suggested outfits" do
      let(:suggested_outfits) do
        [
          {
            items: [double(category: "shirt"), double(category: "pants")],
            reasoning: "Professional and modern",
            confidence: 85
          }
        ]
      end

      it "includes outfit context" do
        prompt = detector.send(:build_detection_prompt)
        expect(prompt).to include("SUGGESTED OUTFITS FOR THIS CONTEXT")
        expect(prompt).to include("confidence: 85")
      end
    end
  end

  describe "#build_wardrobe_summary" do
    before do
      # Add more items for better summary
      create(:wardrobe_item, user: user, category: "dress-shirt", color: "white")
      create(:wardrobe_item, user: user, category: "dress-shirt", color: "blue")
      create(:wardrobe_item, user: user, category: "chinos", color: "khaki")

      # Stub HTTP for these tests (they don't actually call the API)
      stub_request(:post, %r{https://.*aiplatform\.googleapis\.com/.*})
        .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
    end

    it "groups items by normalized category" do
      summary = detector.send(:build_wardrobe_summary)

      expect(summary).to include("CURRENT WARDROBE SUMMARY")
      expect(summary).to include("Categories:")
      expect(summary).to include("tops/shirts")
    end

    it "includes color distribution" do
      summary = detector.send(:build_wardrobe_summary)

      expect(summary).to include("Dominant Colors:")
      expect(summary).to include("blue")
    end

    it "identifies category gaps" do
      summary = detector.send(:build_wardrobe_summary)

      expect(summary).to include("IDENTIFIED GAPS")
    end
  end

  describe "#normalize_category" do
    it "normalizes shirt categories" do
      expect(detector.send(:normalize_category, "T-Shirt")).to eq("tops/shirts")
      expect(detector.send(:normalize_category, "blouse")).to eq("tops/shirts")
      expect(detector.send(:normalize_category, "casual-top")).to eq("tops/shirts")
    end

    it "normalizes pants categories" do
      expect(detector.send(:normalize_category, "jeans")).to eq("pants/jeans")
      expect(detector.send(:normalize_category, "dress-pants")).to eq("pants/jeans")
      expect(detector.send(:normalize_category, "trousers")).to eq("pants/jeans")
    end

    it "normalizes shoe categories" do
      expect(detector.send(:normalize_category, "sneakers")).to eq("shoes")
      expect(detector.send(:normalize_category, "boots")).to eq("shoes")
      expect(detector.send(:normalize_category, "dress-shoes")).to eq("shoes")
    end

    it "handles blank categories" do
      expect(detector.send(:normalize_category, nil)).to eq("unknown")
      expect(detector.send(:normalize_category, "")).to eq("unknown")
    end

    it "preserves unrecognized categories" do
      expect(detector.send(:normalize_category, "custom-item")).to eq("custom-item")
    end
  end

  describe "#identify_category_gaps" do
    it "identifies missing essential categories" do
      category_counts = { "tops/shirts" => 2, "pants/jeans" => 1 }
      result = detector.send(:identify_category_gaps, category_counts)

      expect(result).to include("Missing sufficient shoes")
      expect(result).to include("Missing sufficient outerwear")
    end

    it "reports no gaps when wardrobe is complete" do
      category_counts = {
        "tops/shirts" => 5,
        "pants/jeans" => 3,
        "shoes" => 3,
        "outerwear" => 2
      }
      result = detector.send(:identify_category_gaps, category_counts)

      expect(result).to include("None - wardrobe has good coverage")
    end
  end

  describe "#validate_priority" do
    it "accepts valid priority values" do
      expect(detector.send(:validate_priority, "high")).to eq("high")
      expect(detector.send(:validate_priority, "medium")).to eq("medium")
      expect(detector.send(:validate_priority, "low")).to eq("low")
    end

    it "handles case variations" do
      expect(detector.send(:validate_priority, "HIGH")).to eq("high")
      expect(detector.send(:validate_priority, " Medium ")).to eq("medium")
    end

    it "defaults invalid values to medium" do
      expect(detector.send(:validate_priority, "invalid")).to eq("medium")
      expect(detector.send(:validate_priority, nil)).to eq("medium")
      expect(detector.send(:validate_priority, 123)).to eq("medium")
    end
  end

  describe "error handling" do
    context "when Google Auth fails" do
      it "returns empty array" do
        allow(Google::Auth).to receive(:get_application_default)
          .and_raise(StandardError, "Auth failed")

        result = detector.detect_missing_items
        expect(result).to eq([])
      end
    end

    context "when JSON parsing fails" do
      it "returns empty array" do
        # Return response that is not valid JSON
        invalid_json_response = {
          'candidates' => [
            {
              'content' => {
                'parts' => [
                  {
                    'text' => 'This is not valid JSON at all!'
                  }
                ]
              }
            }
          ]
        }

        stub_request(:post, %r{https://us-central1-aiplatform\.googleapis\.com/.*})
          .to_return(
            status: 200,
            body: invalid_json_response.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )

        result = detector.detect_missing_items
        expect(result).to eq([])
      end
    end
  end

  describe "integration with user profile" do
    context "when user has no profile" do
      it "builds prompt without profile section" do
        prompt = detector.send(:build_detection_prompt)
        expect(prompt).not_to include("USER PROFILE")
      end
    end

    context "when user has complete profile" do
      before { user_profile }

      it "includes all profile fields" do
        prompt = detector.send(:build_detection_prompt)
        expect(prompt).to include("Presentation style: Masculine")
        expect(prompt).to include("Style preference: Business casual")
        expect(prompt).to include("Age range: 25-34")
        expect(prompt).to include("Favorite colors: navy, gray, white")
      end
    end
  end
end
