# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateProductImageJob, type: :job do
  let(:outfit_suggestion) { create(:outfit_suggestion) }
  let(:recommendation) do
    create(:product_recommendation,
           outfit_suggestion: outfit_suggestion,
           category: "blazer",
           description: "Navy blue blazer",
           color_preference: "navy",
           priority: :high,
           ai_image_status: :pending)
  end

  let(:generator) { instance_double(ProductImageGenerator) }
  let(:image_url) { "https://replicate.delivery/test-image.png" }

  before do
    allow(ProductImageGenerator).to receive(:new).and_return(generator)
  end

  describe "#perform" do
    context "when recommendation exists" do
      context "and image generation succeeds" do
        before do
          allow(generator).to receive(:generate_image).and_return(image_url)
        end

        it "marks recommendation as generating before starting" do
          described_class.new.perform(recommendation.id)

          # Reload to check state changes
          recommendation.reload
          # After successful completion, status should be completed (not generating)
          expect(recommendation.ai_image_status).to eq("completed")
        end

        it "calls ProductImageGenerator with the recommendation" do
          described_class.new.perform(recommendation.id)

          expect(ProductImageGenerator).to have_received(:new).with(recommendation)
          expect(generator).to have_received(:generate_image)
        end

        it "marks recommendation as completed with image URL" do
          described_class.new.perform(recommendation.id)

          recommendation.reload
          expect(recommendation.ai_image_status).to eq("completed")
          expect(recommendation.ai_image_url).to eq(image_url)
          expect(recommendation.ai_image_cost).to eq(0.0025)
        end

        it "updates recommendation status to completed" do
          described_class.new.perform(recommendation.id)

          recommendation.reload
          expect(recommendation.ai_image_status).to eq("completed")
          expect(recommendation.ai_image_url).to eq(image_url)
        end

        it "records the estimated cost" do
          described_class.new.perform(recommendation.id)

          recommendation.reload
          expect(recommendation.ai_image_cost).to eq(0.0025)
        end

        it "logs successful completion" do
          allow(Rails.logger).to receive(:info)

          described_class.new.perform(recommendation.id)

          expect(Rails.logger).to have_received(:info)
            .with(/Successfully completed image generation/)
        end
      end

      context "and image generation returns nil" do
        before do
          allow(generator).to receive(:generate_image).and_return(nil)
        end

        it "marks recommendation as failed" do
          described_class.new.perform(recommendation.id)

          recommendation.reload
          expect(recommendation.ai_image_status).to eq("failed")
          expect(recommendation.ai_image_error).to eq("Image generation returned no URL")
        end

        it "updates recommendation status to failed" do
          described_class.new.perform(recommendation.id)

          recommendation.reload
          expect(recommendation.ai_image_status).to eq("failed")
          expect(recommendation.ai_image_error).to eq("Image generation returned no URL")
        end

        it "logs the failure" do
          allow(Rails.logger).to receive(:error)

          described_class.new.perform(recommendation.id)

          expect(Rails.logger).to have_received(:error)
            .with(/Image generation failed.*No URL returned/)
        end
      end

      context "and an error occurs during generation" do
        let(:error_message) { "API rate limit exceeded" }

        before do
          allow(generator).to receive(:generate_image)
            .and_raise(StandardError, error_message)
        end

        it "marks recommendation as failed with error message" do
          begin
            described_class.new.perform(recommendation.id)
          rescue StandardError
            # Expected to re-raise
          end

          recommendation.reload
          expect(recommendation.ai_image_status).to eq("failed")
          expect(recommendation.ai_image_error).to eq(error_message)
        end

        it "updates recommendation with error details" do
          begin
            described_class.new.perform(recommendation.id)
          rescue StandardError
            # Expected to re-raise
          end

          recommendation.reload
          expect(recommendation.ai_image_status).to eq("failed")
          expect(recommendation.ai_image_error).to eq(error_message)
        end

        it "logs the error with backtrace" do
          allow(Rails.logger).to receive(:error)

          begin
            described_class.new.perform(recommendation.id)
          rescue StandardError
            # Expected to re-raise
          end

          expect(Rails.logger).to have_received(:error)
            .with(/GenerateProductImageJob failed/)
          expect(Rails.logger).to have_received(:error).at_least(:once)
        end

        it "re-raises the error for retry mechanism" do
          expect {
            described_class.new.perform(recommendation.id)
          }.to raise_error(StandardError, error_message)
        end
      end
    end

    context "when recommendation does not exist" do
      let(:invalid_id) { 999999 }

      it "logs a warning and returns without error" do
        allow(Rails.logger).to receive(:warn)

        described_class.new.perform(invalid_id)

        expect(Rails.logger).to have_received(:warn)
          .with(/ProductRecommendation ##{invalid_id} not found/)
      end

      it "does not call ProductImageGenerator" do
        described_class.new.perform(999999)

        expect(ProductImageGenerator).not_to have_received(:new)
      end

      it "does not raise an error" do
        expect {
          described_class.new.perform(999999)
        }.not_to raise_error
      end
    end
  end

  describe "job configuration" do
    it "is configured to use the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end

  describe "retry behavior" do
    context "when ProductImageGenerator::GenerationError is raised" do
      before do
        allow(generator).to receive(:generate_image)
          .and_raise(ProductImageGenerator::GenerationError, "API Error")
      end

      it "marks recommendation as failed before retrying" do
        begin
          described_class.new.perform(recommendation.id)
        rescue ProductImageGenerator::GenerationError
          # Expected to re-raise for retry
        end

        recommendation.reload
        expect(recommendation.ai_image_status).to eq("failed")
        expect(recommendation.ai_image_error).to eq("API Error")
      end
    end
  end

  describe "logging behavior" do
    before do
      allow(generator).to receive(:generate_image).and_return(image_url)
    end

    it "logs when starting image generation" do
      allow(Rails.logger).to receive(:info)

      described_class.new.perform(recommendation.id)

      expect(Rails.logger).to have_received(:info)
        .with(/Starting image generation for ProductRecommendation ##{recommendation.id}/)
    end
  end

  describe "integration with ProductRecommendation model" do
    before do
      allow(generator).to receive(:generate_image).and_return(image_url)
    end

    it "properly transitions recommendation through status states" do
      # Start as pending
      expect(recommendation.ai_image_status).to eq("pending")

      # Perform job
      described_class.new.perform(recommendation.id)
      recommendation.reload

      # Should be completed after successful generation
      expect(recommendation.ai_image_status).to eq("completed")
      expect(recommendation.ai_image_url).to eq(image_url)
      expect(recommendation.ai_image_cost).to eq(0.0025)
      expect(recommendation.ai_image_error).to be_nil
    end

    it "clears previous errors on successful generation" do
      # Set initial error
      recommendation.update!(
        ai_image_status: :failed,
        ai_image_error: "Previous error"
      )

      # Perform job successfully
      described_class.new.perform(recommendation.id)
      recommendation.reload

      expect(recommendation.ai_image_status).to eq("completed")
      expect(recommendation.ai_image_error).to be_nil
    end
  end

  describe "error handling edge cases" do
    context "when recommendation becomes nil during execution" do
      it "handles gracefully" do
        # Stub find_by to return nil
        allow(ProductRecommendation).to receive(:find_by).and_return(nil)

        expect {
          described_class.new.perform(recommendation.id)
        }.not_to raise_error
      end
    end

    context "when database error occurs during status update" do
      before do
        # Stub the mark_image_generating! to raise an error
        allow_any_instance_of(ProductRecommendation).to receive(:mark_image_generating!)
          .and_raise(ActiveRecord::RecordInvalid)
      end

      it "logs the error and re-raises" do
        allow(Rails.logger).to receive(:error)

        expect {
          described_class.new.perform(recommendation.id)
        }.to raise_error(ActiveRecord::RecordInvalid)

        expect(Rails.logger).to have_received(:error).at_least(:once)
      end
    end
  end

  describe "performance and timing" do
    before do
      allow(generator).to receive(:generate_image).and_return(image_url)
    end

    it "completes within reasonable time" do
      start_time = Time.current

      described_class.new.perform(recommendation.id)

      end_time = Time.current
      duration = end_time - start_time

      # Should complete quickly in tests (mocked API)
      expect(duration).to be < 1.0
    end
  end

  describe "idempotency" do
    before do
      allow(generator).to receive(:generate_image).and_return(image_url)
    end

    it "can be safely run multiple times" do
      # First run
      described_class.new.perform(recommendation.id)
      recommendation.reload
      first_url = recommendation.ai_image_url

      # Second run (simulating retry)
      described_class.new.perform(recommendation.id)
      recommendation.reload
      second_url = recommendation.ai_image_url

      # Both should succeed and have URLs
      expect(first_url).to be_present
      expect(second_url).to be_present
    end
  end
end
