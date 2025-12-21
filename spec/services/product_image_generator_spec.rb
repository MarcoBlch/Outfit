# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProductImageGenerator, type: :service do
  let(:outfit_suggestion) { create(:outfit_suggestion) }
  let(:recommendation) do
    create(:product_recommendation,
           outfit_suggestion: outfit_suggestion,
           category: "blazer",
           description: "Navy blue blazer",
           color_preference: "navy",
           style_notes: "Professional and modern",
           priority: :high,
           budget_range: :mid_range,
           ai_image_status: :pending)
  end

  subject(:generator) { described_class.new(recommendation) }

  before do
    # Set API token for tests
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('REPLICATE_API_TOKEN').and_return('test_token_123')
  end

  describe "#initialize" do
    it "sets the recommendation instance variable" do
      expect(generator.instance_variable_get(:@recommendation)).to eq(recommendation)
    end

    it "retrieves the API token from environment" do
      expect(generator.instance_variable_get(:@api_token)).to eq('test_token_123')
    end
  end

  describe "#generate_image" do
    let(:image_url) { "https://replicate.delivery/pbxt/test-image.png" }

    context "when API call succeeds" do
      before do
        # Mock the API call
        allow(generator).to receive(:call_replicate_api).and_return(image_url)
      end

      it "generates and returns an image URL" do
        result = generator.generate_image
        expect(result).to eq(image_url)
      end

      it "logs successful generation" do
        allow(Rails.logger).to receive(:info)
        generator.generate_image
        expect(Rails.logger).to have_received(:info).with(/Successfully generated image/)
      end
    end

    context "when API token is missing" do
      before do
        allow(ENV).to receive(:[]).with('REPLICATE_API_TOKEN').and_return(nil)
      end

      it "returns nil" do
        result = generator.generate_image
        expect(result).to be_nil
      end

      it "logs the error" do
        allow(Rails.logger).to receive(:error)
        generator.generate_image
        expect(Rails.logger).to have_received(:error).with(/REPLICATE_API_TOKEN not configured/)
      end
    end

    context "when API call fails" do
      before do
        allow(generator).to receive(:call_replicate_api)
          .and_raise(ProductImageGenerator::GenerationError, "API Error")
      end

      it "returns nil" do
        result = generator.generate_image
        expect(result).to be_nil
      end

      it "logs the error" do
        allow(Rails.logger).to receive(:error)
        generator.generate_image
        expect(Rails.logger).to have_received(:error)
          .with(/ProductImageGenerator failed/)
      end
    end

    context "when unexpected error occurs" do
      before do
        allow(generator).to receive(:call_replicate_api)
          .and_raise(StandardError, "Unexpected error")
      end

      it "returns nil" do
        result = generator.generate_image
        expect(result).to be_nil
      end

      it "logs the unexpected error with backtrace" do
        allow(Rails.logger).to receive(:error)
        generator.generate_image
        expect(Rails.logger).to have_received(:error)
          .with(/Unexpected error in ProductImageGenerator/)
      end
    end

    context "when API returns nil" do
      before do
        allow(generator).to receive(:call_replicate_api).and_return(nil)
      end

      it "returns nil" do
        result = generator.generate_image
        expect(result).to be_nil
      end

      it "logs that generation returned nil" do
        allow(Rails.logger).to receive(:error)
        generator.generate_image
        expect(Rails.logger).to have_received(:error)
          .with(/Image generation returned nil/)
      end
    end
  end

  describe "#build_prompt" do
    it "builds a professional product photography prompt" do
      prompt = generator.send(:build_prompt)

      expect(prompt).to include("Professional product photography")
      expect(prompt).to include("blazer")
      expect(prompt).to include("navy")
      expect(prompt).to include("Professional and modern")
      expect(prompt).to include("clean white background")
      expect(prompt).to include("studio lighting")
      expect(prompt).to include("4k")
    end

    context "with minimal recommendation fields" do
      let(:recommendation) do
        create(:product_recommendation,
               outfit_suggestion: outfit_suggestion,
               category: "item",
               color_preference: "",
               style_notes: "")
      end

      it "uses default values for empty fields" do
        prompt = generator.send(:build_prompt)

        expect(prompt).to include("item")
        expect(prompt).to include("neutral colors")
        expect(prompt).to include("modern style")
      end
    end
  end

  describe "#call_replicate_api" do
    let(:prompt) { "Professional product photography of blazer" }
    let(:prediction_id) { "test-prediction-123" }
    let(:image_url) { "https://replicate.delivery/test-image.png" }

    let(:create_prediction_response) do
      double(
        success?: true,
        parsed_response: { "id" => prediction_id }
      )
    end

    before do
      allow(HTTParty).to receive(:post).and_return(create_prediction_response)
      allow(generator).to receive(:poll_for_completion).and_return(image_url)
    end

    it "creates a prediction request with correct parameters" do
      generator.send(:call_replicate_api, prompt)

      expect(HTTParty).to have_received(:post).with(
        ProductImageGenerator::REPLICATE_API_URL,
        hash_including(
          headers: hash_including(
            "Authorization" => "Token test_token_123",
            "Content-Type" => "application/json"
          )
        )
      )
    end

    it "includes the prompt in the request body" do
      generator.send(:call_replicate_api, prompt)

      expect(HTTParty).to have_received(:post) do |url, options|
        body = JSON.parse(options[:body])
        expect(body["input"]["prompt"]).to eq(prompt)
      end
    end

    it "includes negative prompt to avoid unwanted elements" do
      generator.send(:call_replicate_api, prompt)

      expect(HTTParty).to have_received(:post) do |url, options|
        body = JSON.parse(options[:body])
        expect(body["input"]["negative_prompt"]).to include("person")
        expect(body["input"]["negative_prompt"]).to include("human")
      end
    end

    it "sets appropriate image dimensions and quality settings" do
      generator.send(:call_replicate_api, prompt)

      expect(HTTParty).to have_received(:post) do |url, options|
        body = JSON.parse(options[:body])
        expect(body["input"]["width"]).to eq(1024)
        expect(body["input"]["height"]).to eq(1024)
        expect(body["input"]["num_inference_steps"]).to eq(30)
      end
    end

    it "polls for completion after creating prediction" do
      generator.send(:call_replicate_api, prompt)

      expect(generator).to have_received(:poll_for_completion).with(prediction_id)
    end

    it "returns the generated image URL" do
      result = generator.send(:call_replicate_api, prompt)
      expect(result).to eq(image_url)
    end

    context "when API request fails" do
      let(:error_response) do
        double(
          success?: false,
          code: 401,
          body: "Unauthorized",
          parsed_response: { "detail" => "Invalid token" }
        )
      end

      before do
        allow(HTTParty).to receive(:post).and_return(error_response)
      end

      it "raises GenerationError" do
        expect {
          generator.send(:call_replicate_api, prompt)
        }.to raise_error(ProductImageGenerator::GenerationError, /Invalid token/)
      end

      it "logs the API error" do
        allow(Rails.logger).to receive(:error)

        begin
          generator.send(:call_replicate_api, prompt)
        rescue ProductImageGenerator::GenerationError
          # Expected error
        end

        expect(Rails.logger).to have_received(:error).with(/Replicate API Error/)
      end
    end

    context "when network error occurs" do
      before do
        allow(HTTParty).to receive(:post).and_raise(HTTParty::Error.new("Connection failed"))
      end

      it "raises GenerationError with network error message" do
        expect {
          generator.send(:call_replicate_api, prompt)
        }.to raise_error(ProductImageGenerator::GenerationError, /Network error/)
      end

      it "logs the network error" do
        allow(Rails.logger).to receive(:error)

        begin
          generator.send(:call_replicate_api, prompt)
        rescue ProductImageGenerator::GenerationError
          # Expected error
        end

        expect(Rails.logger).to have_received(:error)
          .with(/Network error calling Replicate API/)
      end
    end

    context "when prediction ID is missing" do
      let(:create_prediction_response) do
        double(success?: true, parsed_response: {})
      end

      it "raises GenerationError" do
        expect {
          generator.send(:call_replicate_api, prompt)
        }.to raise_error(ProductImageGenerator::GenerationError, /No prediction ID/)
      end
    end
  end

  describe "#poll_for_completion" do
    let(:prediction_id) { "test-prediction-123" }
    let(:image_url) { "https://replicate.delivery/test-image.png" }

    context "when prediction succeeds immediately" do
      let(:success_response) do
        double(
          success?: true,
          parsed_response: {
            "status" => "succeeded",
            "output" => [image_url]
          }
        )
      end

      before do
        allow(HTTParty).to receive(:get).and_return(success_response)
      end

      it "returns the image URL" do
        result = generator.send(:poll_for_completion, prediction_id)
        expect(result).to eq(image_url)
      end

      it "logs the successful status" do
        allow(Rails.logger).to receive(:info)
        generator.send(:poll_for_completion, prediction_id)
        expect(Rails.logger).to have_received(:info)
          .with(/Prediction.*status: succeeded/)
      end
    end

    context "when prediction succeeds after processing" do
      let(:processing_response) do
        double(
          success?: true,
          parsed_response: { "status" => "processing" }
        )
      end

      let(:success_response) do
        double(
          success?: true,
          parsed_response: {
            "status" => "succeeded",
            "output" => image_url # String format
          }
        )
      end

      before do
        allow(HTTParty).to receive(:get)
          .and_return(processing_response, success_response)
        allow(generator).to receive(:sleep) # Prevent actual sleeping
      end

      it "polls until completion" do
        result = generator.send(:poll_for_completion, prediction_id)
        expect(result).to eq(image_url)
        expect(HTTParty).to have_received(:get).twice
      end

      it "sleeps between polling attempts" do
        generator.send(:poll_for_completion, prediction_id)
        expect(generator).to have_received(:sleep).with(5).once
      end
    end

    context "when prediction fails" do
      let(:failed_response) do
        double(
          success?: true,
          parsed_response: {
            "status" => "failed",
            "error" => "Model execution failed"
          }
        )
      end

      before do
        allow(HTTParty).to receive(:get).and_return(failed_response)
      end

      it "raises GenerationError with error message" do
        expect {
          generator.send(:poll_for_completion, prediction_id)
        }.to raise_error(ProductImageGenerator::GenerationError, /Model execution failed/)
      end
    end

    context "when prediction is canceled" do
      let(:canceled_response) do
        double(
          success?: true,
          parsed_response: { "status" => "canceled" }
        )
      end

      before do
        allow(HTTParty).to receive(:get).and_return(canceled_response)
      end

      it "raises GenerationError" do
        expect {
          generator.send(:poll_for_completion, prediction_id)
        }.to raise_error(ProductImageGenerator::GenerationError, /canceled/)
      end
    end

    context "when prediction times out" do
      let(:processing_response) do
        double(
          success?: true,
          parsed_response: { "status" => "processing" }
        )
      end

      before do
        allow(HTTParty).to receive(:get).and_return(processing_response)
        allow(generator).to receive(:sleep)
      end

      it "raises GenerationError after max attempts" do
        expect {
          generator.send(:poll_for_completion, prediction_id)
        }.to raise_error(ProductImageGenerator::GenerationError, /timed out/)
      end
    end

    context "when status check request fails" do
      let(:error_response) do
        double(success?: false, code: 500)
      end

      before do
        allow(HTTParty).to receive(:get).and_return(error_response)
      end

      it "raises GenerationError" do
        expect {
          generator.send(:poll_for_completion, prediction_id)
        }.to raise_error(ProductImageGenerator::GenerationError, /Failed to check prediction status/)
      end
    end

    context "when output has no image URL" do
      let(:success_response) do
        double(
          success?: true,
          parsed_response: {
            "status" => "succeeded",
            "output" => nil
          }
        )
      end

      before do
        allow(HTTParty).to receive(:get).and_return(success_response)
      end

      it "raises GenerationError" do
        expect {
          generator.send(:poll_for_completion, prediction_id)
        }.to raise_error(ProductImageGenerator::GenerationError, /No image URL/)
      end
    end

    context "when network error occurs during polling" do
      before do
        allow(HTTParty).to receive(:get).and_raise(Net::OpenTimeout)
      end

      it "raises GenerationError with network error message" do
        expect {
          generator.send(:poll_for_completion, prediction_id)
        }.to raise_error(ProductImageGenerator::GenerationError, /Network error while polling/)
      end
    end
  end

  describe "error handling" do
    context "when API token is blank" do
      before do
        allow(ENV).to receive(:[]).with('REPLICATE_API_TOKEN').and_return("")
      end

      it "handles blank token gracefully" do
        result = generator.generate_image
        expect(result).to be_nil
      end
    end
  end

  describe "integration scenarios" do
    let(:image_url) { "https://replicate.delivery/final-image.png" }

    context "complete successful flow" do
      let(:create_response) do
        double(success?: true, parsed_response: { "id" => "pred-123" })
      end

      let(:poll_response) do
        double(
          success?: true,
          parsed_response: {
            "status" => "succeeded",
            "output" => [image_url]
          }
        )
      end

      before do
        allow(HTTParty).to receive(:post).and_return(create_response)
        allow(HTTParty).to receive(:get).and_return(poll_response)
      end

      it "successfully generates image end-to-end" do
        result = generator.generate_image

        expect(result).to eq(image_url)
        expect(HTTParty).to have_received(:post).once
        expect(HTTParty).to have_received(:get).once
      end
    end
  end
end
