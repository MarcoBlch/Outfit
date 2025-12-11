require 'rails_helper'

RSpec.describe Analytics::SubscriptionMetrics, type: :model do
  let(:metrics) { described_class.new }

  describe "#mrr" do
    context "with paying users" do
      before do
        create_list(:user, 10, :premium)
        create_list(:user, 5, :pro)
      end

      it "calculates total MRR correctly" do
        result = metrics.mrr
        expected_total = (10 * 7.99) + (5 * 14.99)

        expect(result[:total]).to eq(expected_total)
      end

      it "calculates premium MRR correctly" do
        result = metrics.mrr
        expect(result[:premium]).to eq(10 * 7.99)
      end

      it "calculates pro MRR correctly" do
        result = metrics.mrr
        expect(result[:pro]).to eq(5 * 14.99)
      end
    end

    context "with no paying users" do
      before { create_list(:user, 5) }

      it "returns zero MRR" do
        result = metrics.mrr
        expect(result[:total]).to eq(0)
      end
    end
  end

  describe "#mrr_breakdown" do
    before do
      create_list(:user, 3, :premium)
      create_list(:user, 2, :pro)
    end

    it "includes premium breakdown" do
      result = metrics.mrr_breakdown

      expect(result[:premium][:count]).to eq(3)
      expect(result[:premium][:price]).to eq(7.99)
      expect(result[:premium][:total]).to eq(3 * 7.99)
    end

    it "includes pro breakdown" do
      result = metrics.mrr_breakdown

      expect(result[:pro][:count]).to eq(2)
      expect(result[:pro][:price]).to eq(14.99)
      expect(result[:pro][:total]).to eq(2 * 14.99)
    end
  end

  describe "#total_paying_customers" do
    before do
      create_list(:user, 10)
      create_list(:user, 5, :premium)
      create_list(:user, 3, :pro)
    end

    it "counts only premium and pro users" do
      expect(metrics.total_paying_customers).to eq(8)
    end
  end

  describe "#conversion_rates" do
    before do
      create_list(:user, 10)
      create_list(:user, 5, :premium)
      create_list(:user, 2, :pro)
    end

    it "calculates free to paying conversion rate" do
      result = metrics.conversion_rates
      total_users = 17
      paying_users = 7

      expected_rate = (paying_users.to_f / total_users * 100).round(2)
      expect(result[:free_to_paying]).to eq(expected_rate)
    end

    it "calculates free to premium conversion rate" do
      result = metrics.conversion_rates
      total_users = 17
      premium_users = 5

      expected_rate = (premium_users.to_f / total_users * 100).round(2)
      expect(result[:free_to_premium]).to eq(expected_rate)
    end

    it "calculates premium to pro conversion rate" do
      result = metrics.conversion_rates
      paying_users = 7
      pro_users = 2

      expected_rate = (pro_users.to_f / paying_users * 100).round(2)
      expect(result[:premium_to_pro]).to eq(expected_rate)
    end

    context "with no users" do
      it "returns zero conversion rates" do
        result = metrics.conversion_rates
        expect(result[:free_to_paying]).to eq(0)
        expect(result[:free_to_premium]).to eq(0)
        expect(result[:premium_to_pro]).to eq(0)
      end
    end
  end

  describe "#arpu" do
    before do
      create_list(:user, 10)
      create_list(:user, 5, :premium)
      create_list(:user, 2, :pro)
    end

    it "calculates average revenue per user" do
      total_mrr = (5 * 7.99) + (2 * 14.99)
      total_users = 17

      expected_arpu = (total_mrr / total_users).round(2)
      expect(metrics.arpu).to eq(expected_arpu)
    end

    context "with no users" do
      before { User.destroy_all }

      it "returns zero ARPU" do
        expect(metrics.arpu).to eq(0)
      end
    end
  end

  describe "#active_subscriptions_by_tier" do
    before do
      create_list(:user, 20)
      create_list(:user, 10, :premium)
      create_list(:user, 5, :pro)
    end

    it "returns correct counts for each tier" do
      result = metrics.active_subscriptions_by_tier

      expect(result[:free]).to eq(20)
      expect(result[:premium]).to eq(10)
      expect(result[:pro]).to eq(5)
    end
  end

  describe "#tier_distribution" do
    before do
      create_list(:user, 20)
      create_list(:user, 10, :premium)
      create_list(:user, 5, :pro)
    end

    it "returns distribution hash with proper keys" do
      result = metrics.tier_distribution

      expect(result["Free"]).to eq(20)
      expect(result["Premium"]).to eq(10)
      expect(result["Pro"]).to eq(5)
    end

    context "with no users" do
      before { User.destroy_all }

      it "returns empty hash" do
        expect(metrics.tier_distribution).to eq({})
      end
    end
  end

  describe "#churn_rate" do
    it "returns a numeric value" do
      expect(metrics.churn_rate).to be_a(Numeric)
    end

    it "returns zero when no paying customers exist" do
      create_list(:user, 10)
      expect(metrics.churn_rate).to eq(0)
    end
  end

  describe "#mrr_over_time" do
    before do
      create(:user, :premium, created_at: 10.days.ago)
      create(:user, :premium, created_at: 5.days.ago)
      create(:user, :pro, created_at: 2.days.ago)
    end

    it "returns a hash" do
      result = metrics.mrr_over_time(30)
      expect(result).to be_a(Hash)
    end

    it "includes data for the specified period" do
      result = metrics.mrr_over_time(30)
      expect(result.keys.length).to be > 0
    end
  end

  describe "#signups_by_week" do
    before do
      create(:user, created_at: 2.weeks.ago)
      create(:user, created_at: 1.week.ago)
      create(:user, created_at: Time.current)
    end

    it "returns a hash" do
      result = metrics.signups_by_week(12)
      expect(result).to be_a(Hash)
    end

    it "groups signups by week" do
      result = metrics.signups_by_week(12)
      expect(result.values.sum).to eq(3)
    end
  end
end
