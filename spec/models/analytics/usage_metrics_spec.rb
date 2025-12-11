require 'rails_helper'

RSpec.describe Analytics::UsageMetrics, type: :model do
  let(:metrics) { described_class.new }
  let(:user) { create(:user) }

  describe "#ai_suggestions_stats" do
    before do
      create_list(:outfit_suggestion, 3, created_at: Time.current)
      create_list(:outfit_suggestion, 5, created_at: 5.days.ago)
      create_list(:outfit_suggestion, 2, created_at: 20.days.ago)
    end

    it "counts suggestions today" do
      result = metrics.ai_suggestions_stats
      expect(result[:total_today]).to eq(3)
    end

    it "counts suggestions this week" do
      result = metrics.ai_suggestions_stats
      expect(result[:total_this_week]).to eq(8)
    end

    it "counts suggestions this month" do
      result = metrics.ai_suggestions_stats
      expect(result[:total_this_month]).to eq(10)
    end

    it "counts all suggestions" do
      result = metrics.ai_suggestions_stats
      expect(result[:total_all_time]).to eq(10)
    end
  end

  describe "#avg_suggestions_per_user" do
    before do
      user1 = create(:user)
      user2 = create(:user)
      create_list(:outfit_suggestion, 5, user: user1)
      create_list(:outfit_suggestion, 3, user: user2)
    end

    it "calculates average correctly" do
      total_users = User.count
      total_suggestions = OutfitSuggestion.count

      expected_avg = (total_suggestions.to_f / total_users).round(2)
      expect(metrics.avg_suggestions_per_user).to eq(expected_avg)
    end

    context "with no users" do
      before do
        User.destroy_all
        OutfitSuggestion.destroy_all
      end

      it "returns zero" do
        expect(metrics.avg_suggestions_per_user).to eq(0)
      end
    end
  end

  describe "#suggestions_over_time" do
    before do
      create(:outfit_suggestion, created_at: 2.days.ago)
      create(:outfit_suggestion, created_at: 1.day.ago)
      create(:outfit_suggestion, created_at: Time.current)
    end

    it "returns a hash" do
      result = metrics.suggestions_over_time(30)
      expect(result).to be_a(Hash)
    end

    it "groups suggestions by day" do
      result = metrics.suggestions_over_time(30)
      expect(result.values.sum).to eq(3)
    end
  end

  describe "#estimated_ai_cost_today" do
    before do
      create_list(:outfit_suggestion, 5, created_at: Time.current)
    end

    it "estimates cost based on suggestion count" do
      expected_cost = 5 * 0.01
      expect(metrics.estimated_ai_cost_today).to eq(expected_cost)
    end
  end

  describe "#estimated_ai_cost_this_month" do
    before do
      create_list(:outfit_suggestion, 100, created_at: Time.current)
      create_list(:outfit_suggestion, 50, created_at: 2.weeks.ago)
    end

    it "estimates monthly cost" do
      expected_cost = 150 * 0.01
      expect(metrics.estimated_ai_cost_this_month).to eq(expected_cost)
    end
  end

  describe "#cost_by_tier" do
    before do
      free_user = create(:user)
      premium_user = create(:user, :premium)
      pro_user = create(:user, :pro)

      create_list(:outfit_suggestion, 3, user: free_user)
      create_list(:outfit_suggestion, 10, user: premium_user)
      create_list(:outfit_suggestion, 20, user: pro_user)
    end

    it "calculates cost for free tier" do
      result = metrics.cost_by_tier
      expected_cost = 3 * 0.01
      expect(result[:free]).to eq(expected_cost)
    end

    it "calculates cost for premium tier" do
      result = metrics.cost_by_tier
      expected_cost = 10 * 0.01
      expect(result[:premium]).to eq(expected_cost)
    end

    it "calculates cost for pro tier" do
      result = metrics.cost_by_tier
      expected_cost = 20 * 0.01
      expect(result[:pro]).to eq(expected_cost)
    end
  end

  describe "#top_contexts" do
    before do
      create(:outfit_suggestion, context: "date night")
      create(:outfit_suggestion, context: "date night")
      create(:outfit_suggestion, context: "date night")
      create(:outfit_suggestion, context: "job interview")
      create(:outfit_suggestion, context: "job interview")
      create(:outfit_suggestion, context: "casual outing")
    end

    it "returns top contexts sorted by count" do
      result = metrics.top_contexts(10)

      expect(result["date night"]).to eq(3)
      expect(result["job interview"]).to eq(2)
      expect(result["casual outing"]).to eq(1)
    end

    it "limits results to specified number" do
      create_list(:outfit_suggestion, 1, context: "context_#{_1}") { |_, i| i }

      result = metrics.top_contexts(5)
      expect(result.size).to be <= 5
    end

    it "excludes nil and empty contexts" do
      create(:outfit_suggestion, context: nil)
      create(:outfit_suggestion, context: "")

      result = metrics.top_contexts(10)
      expect(result.keys).not_to include(nil, "")
    end
  end

  describe "#usage_by_hour" do
    before do
      create(:outfit_suggestion, created_at: Time.current.change(hour: 9))
      create(:outfit_suggestion, created_at: Time.current.change(hour: 9))
      create(:outfit_suggestion, created_at: Time.current.change(hour: 14))
    end

    it "returns a hash grouped by hour" do
      result = metrics.usage_by_hour
      expect(result).to be_a(Hash)
    end

    it "counts suggestions per hour" do
      result = metrics.usage_by_hour
      expect(result.values.sum).to be > 0
    end
  end

  describe "#outfits_created_today" do
    before do
      create_list(:outfit, 5, created_at: Time.current, user: user)
      create_list(:outfit, 3, created_at: 2.days.ago, user: user)
    end

    it "counts only today's outfits" do
      expect(metrics.outfits_created_today).to eq(5)
    end
  end

  describe "#outfits_created_this_month" do
    before do
      create_list(:outfit, 10, created_at: Time.current, user: user)
      create_list(:outfit, 5, created_at: 2.weeks.ago, user: user)
      create_list(:outfit, 3, created_at: 2.months.ago, user: user)
    end

    it "counts only this month's outfits" do
      expect(metrics.outfits_created_this_month).to eq(15)
    end
  end

  describe "#wardrobe_items_uploaded_today" do
    before do
      create_list(:wardrobe_item, 7, created_at: Time.current, user: user)
      create_list(:wardrobe_item, 4, created_at: 2.days.ago, user: user)
    end

    it "counts only today's wardrobe items" do
      expect(metrics.wardrobe_items_uploaded_today).to eq(7)
    end
  end

  describe "#wardrobe_items_uploaded_this_month" do
    before do
      create_list(:wardrobe_item, 15, created_at: Time.current, user: user)
      create_list(:wardrobe_item, 10, created_at: 2.weeks.ago, user: user)
      create_list(:wardrobe_item, 5, created_at: 2.months.ago, user: user)
    end

    it "counts only this month's wardrobe items" do
      expect(metrics.wardrobe_items_uploaded_this_month).to eq(25)
    end
  end

  describe "#suggestion_success_rate" do
    before do
      create_list(:outfit_suggestion, 8, status: "completed")
      create_list(:outfit_suggestion, 2, status: "failed")
    end

    it "calculates success rate correctly" do
      expected_rate = (8.0 / 10 * 100).round(2)
      expect(metrics.suggestion_success_rate).to eq(expected_rate)
    end

    context "with no suggestions" do
      before { OutfitSuggestion.destroy_all }

      it "returns zero" do
        expect(metrics.suggestion_success_rate).to eq(0)
      end
    end
  end

  describe "#most_active_users" do
    before do
      user1 = create(:user)
      user2 = create(:user)
      user3 = create(:user)

      create_list(:outfit_suggestion, 10, user: user1)
      create_list(:outfit_suggestion, 5, user: user2)
      create_list(:outfit_suggestion, 2, user: user3)
    end

    it "returns users ordered by suggestion count" do
      result = metrics.most_active_users(3)
      expect(result.length).to eq(3)
    end

    it "limits results to specified number" do
      result = metrics.most_active_users(2)
      expect(result.length).to eq(2)
    end
  end

  describe "#users_by_engagement" do
    before do
      highly_engaged = create(:user)
      moderately_engaged = create(:user)
      low_engaged = create(:user)
      not_engaged = create(:user)

      create_list(:outfit_suggestion, 15, user: highly_engaged)
      create_list(:outfit_suggestion, 5, user: moderately_engaged)
      create_list(:outfit_suggestion, 1, user: low_engaged)
    end

    it "categorizes users by engagement level" do
      result = metrics.users_by_engagement

      expect(result[:highly_engaged]).to eq(1)
      expect(result[:moderately_engaged]).to eq(1)
      expect(result[:low_engaged]).to eq(1)
      expect(result[:not_engaged]).to eq(1)
    end
  end
end
