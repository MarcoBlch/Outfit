# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "OutfitSuggestions", type: :request do
  let(:user) { create(:user) }
  let(:outfit_suggestion) { create(:outfit_suggestion, :with_suggestions, user: user) }

  before do
    sign_in user
  end

  describe "GET /outfit_suggestions" do
    it "returns http success" do
      get outfit_suggestions_path
      expect(response).to have_http_status(:success)
    end

    it "displays user's outfit suggestions" do
      outfit_suggestion # create the suggestion
      get outfit_suggestions_path
      expect(response.body).to include("Outfit Suggestions")
    end
  end

  describe "GET /outfit_suggestions/:id" do
    it "returns http success" do
      get outfit_suggestion_path(outfit_suggestion)
      expect(response).to have_http_status(:success)
    end

    it "shows the outfit suggestion details" do
      get outfit_suggestion_path(outfit_suggestion)
      expect(assigns(:suggestion)).to eq(outfit_suggestion)
    end
  end

  describe "POST /outfit_suggestions" do
    let(:valid_params) { { context: "Business meeting downtown" } }

    before do
      # Mock the OutfitSuggestionService
      allow_any_instance_of(OutfitSuggestionService).to receive(:generate_suggestions).and_return([
        {
          rank: 1,
          confidence: 0.95,
          reasoning: "Professional outfit",
          items: []
        }
      ])

      # Mock MissingItemDetector to avoid calling real API
      allow_any_instance_of(MissingItemDetector).to receive(:detect_missing_items).and_return([
        {
          category: "blazer",
          description: "Navy blue blazer",
          color_preference: "navy",
          style_notes: "Professional",
          reasoning: "Completes business outfit",
          priority: "high",
          budget_range: "$100-200"
        }
      ])
    end

    context "with valid parameters" do
      it "creates a new outfit suggestion" do
        expect {
          post outfit_suggestions_path, params: valid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change(OutfitSuggestion, :count).by(1)
      end

      it "triggers product recommendation workflow" do
        expect(MissingItemDetector).to receive(:new).and_call_original

        post outfit_suggestions_path, params: valid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
      end

      it "creates product recommendations" do
        expect {
          post outfit_suggestions_path, params: valid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change(ProductRecommendation, :count).by(1)
      end

      it "enqueues background jobs" do
        expect {
          post outfit_suggestions_path, params: valid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to have_enqueued_job(GenerateProductImageJob)
          .and have_enqueued_job(FetchAffiliateProductsJob)
      end

      it "does not fail if product recommendation workflow errors" do
        allow_any_instance_of(MissingItemDetector).to receive(:detect_missing_items).and_raise(StandardError, "API Error")

        expect {
          post outfit_suggestions_path, params: valid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change(OutfitSuggestion, :count).by(1)

        expect(response).to have_http_status(:success)
      end
    end

    context "with invalid parameters" do
      it "returns error when context is blank" do
        post outfit_suggestions_path, params: { context: "" }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when rate limited" do
      before do
        allow(user).to receive(:can_request_suggestion?).and_return(false)
      end

      it "returns too many requests status" do
        post outfit_suggestions_path, params: valid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        expect(response).to have_http_status(:too_many_requests)
      end
    end
  end

  describe "GET /outfit_suggestions/:id/show_recommendations" do
    let!(:recommendation1) { create(:product_recommendation, outfit_suggestion: outfit_suggestion, priority: :high) }
    let!(:recommendation2) { create(:product_recommendation, outfit_suggestion: outfit_suggestion, priority: :medium) }

    it "returns http success" do
      get show_recommendations_outfit_suggestion_path(outfit_suggestion)
      expect(response).to have_http_status(:success)
    end

    it "loads recommendations ordered by priority" do
      get show_recommendations_outfit_suggestion_path(outfit_suggestion)
      expect(assigns(:recommendations)).to eq([recommendation1, recommendation2])
    end

    it "eager loads outfit_suggestion association" do
      get show_recommendations_outfit_suggestion_path(outfit_suggestion)

      # Verify no N+1 queries by checking that associations are loaded
      expect(assigns(:recommendations).first.association(:outfit_suggestion).loaded?).to be true
    end
  end

  describe "POST /outfit_suggestions/:id/recommendations/:recommendation_id/record_view" do
    let(:recommendation) { create(:product_recommendation, outfit_suggestion: outfit_suggestion, views: 5) }

    it "increments the views counter" do
      expect {
        post record_recommendation_view_outfit_suggestion_path(outfit_suggestion, recommendation_id: recommendation.id)
      }.to change { recommendation.reload.views }.by(1)
    end

    it "returns http ok" do
      post record_recommendation_view_outfit_suggestion_path(outfit_suggestion, recommendation_id: recommendation.id)
      expect(response).to have_http_status(:ok)
    end

    context "when recommendation not found" do
      it "returns not found status" do
        post record_recommendation_view_outfit_suggestion_path(outfit_suggestion, recommendation_id: 99999)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /outfit_suggestions/:id/recommendations/:recommendation_id/record_click" do
    let(:recommendation) { create(:product_recommendation, outfit_suggestion: outfit_suggestion, clicks: 3) }

    it "increments the clicks counter" do
      expect {
        post record_recommendation_click_outfit_suggestion_path(outfit_suggestion, recommendation_id: recommendation.id)
      }.to change { recommendation.reload.clicks }.by(1)
    end

    it "returns http ok" do
      post record_recommendation_click_outfit_suggestion_path(outfit_suggestion, recommendation_id: recommendation.id)
      expect(response).to have_http_status(:ok)
    end

    context "when affiliate products are available" do
      before do
        recommendation.update!(
          affiliate_products: [
            {
              'title' => 'Test Product',
              'url' => 'https://amazon.com/test',
              'price' => 99.99
            }
          ]
        )
      end

      it "returns the affiliate URL in JSON" do
        post record_recommendation_click_outfit_suggestion_path(outfit_suggestion, recommendation_id: recommendation.id)

        json_response = JSON.parse(response.body)
        expect(json_response['url']).to eq('https://amazon.com/test')
      end
    end

    context "when recommendation not found" do
      it "returns not found status" do
        post record_recommendation_click_outfit_suggestion_path(outfit_suggestion, recommendation_id: 99999)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "unauthorized access" do
    before { sign_out user }

    it "redirects to sign in for index" do
      get outfit_suggestions_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to sign in for show" do
      get outfit_suggestion_path(outfit_suggestion)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "redirects to sign in for create" do
      post outfit_suggestions_path, params: { context: "test" }
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "accessing other user's suggestions" do
    let(:other_user) { create(:user) }
    let(:other_suggestion) { create(:outfit_suggestion, user: other_user) }

    it "raises not found error" do
      expect {
        get outfit_suggestion_path(other_suggestion)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "budget range mapping" do
    let(:controller) { OutfitSuggestionsController.new }

    it "maps budget string to enum correctly" do
      expect(controller.send(:map_budget_range, "$40-50")).to eq(:budget)
      expect(controller.send(:map_budget_range, "$60-120")).to eq(:mid_range)
      expect(controller.send(:map_budget_range, "$200-300")).to eq(:premium)
      expect(controller.send(:map_budget_range, "$400-600")).to eq(:luxury)
    end

    it "defaults to mid_range for blank budget" do
      expect(controller.send(:map_budget_range, "")).to eq(:mid_range)
      expect(controller.send(:map_budget_range, nil)).to eq(:mid_range)
    end
  end

  describe "priority mapping" do
    let(:controller) { OutfitSuggestionsController.new }

    it "maps priority string to enum correctly" do
      expect(controller.send(:map_priority_to_enum, "high")).to eq(:high)
      expect(controller.send(:map_priority_to_enum, "medium")).to eq(:medium)
      expect(controller.send(:map_priority_to_enum, "low")).to eq(:low)
    end

    it "defaults to medium for unknown priority" do
      expect(controller.send(:map_priority_to_enum, "unknown")).to eq(:medium)
      expect(controller.send(:map_priority_to_enum, "")).to eq(:medium)
    end
  end
end
