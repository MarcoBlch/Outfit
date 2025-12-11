require 'rails_helper'

RSpec.describe "Admin::Metrics", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe "GET /admin/metrics/subscriptions" do
    context "when user is an admin" do
      before do
        sign_in admin_user
        create_list(:user, 10, :premium)
        create_list(:user, 5, :pro)
        create_list(:user, 20)
      end

      it "returns http success" do
        get admin_metrics_subscriptions_path
        expect(response).to have_http_status(:success)
      end

      it "loads subscription metrics" do
        get admin_metrics_subscriptions_path
        expect(assigns(:subscription_metrics)).to be_a(Analytics::SubscriptionMetrics)
      end

      it "calculates MRR correctly" do
        get admin_metrics_subscriptions_path
        mrr = assigns(:mrr)

        expect(mrr[:total]).to be > 0
        expect(mrr[:premium]).to eq(10 * 7.99)
        expect(mrr[:pro]).to eq(5 * 14.99)
      end

      it "calculates conversion rates" do
        get admin_metrics_subscriptions_path
        conversion_rates = assigns(:conversion_rates)

        expect(conversion_rates).to have_key(:free_to_paying)
        expect(conversion_rates).to have_key(:free_to_premium)
        expect(conversion_rates).to have_key(:premium_to_pro)
      end

      it "shows active subscriptions by tier" do
        get admin_metrics_subscriptions_path
        active_subscriptions = assigns(:active_subscriptions)

        expect(active_subscriptions[:premium]).to eq(10)
        expect(active_subscriptions[:pro]).to eq(5)
      end

      it "provides MRR over time data" do
        get admin_metrics_subscriptions_path
        expect(assigns(:mrr_over_time)).to be_a(Hash)
      end

      it "provides signups by week data" do
        get admin_metrics_subscriptions_path
        expect(assigns(:signups_by_week)).to be_a(Hash)
      end
    end

    context "when user is not an admin" do
      before { sign_in regular_user }

      it "redirects to root path" do
        get admin_metrics_subscriptions_path
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /admin/metrics/usage" do
    context "when user is an admin" do
      before do
        sign_in admin_user
        create_list(:outfit_suggestion, 15, created_at: Time.current)
        create_list(:outfit_suggestion, 10, created_at: 1.week.ago)
        create_list(:ad_impression, 20, user: regular_user)
      end

      it "returns http success" do
        get admin_metrics_usage_path
        expect(response).to have_http_status(:success)
      end

      it "loads usage metrics" do
        get admin_metrics_usage_path
        expect(assigns(:usage_metrics)).to be_a(Analytics::UsageMetrics)
      end

      it "shows AI suggestion stats" do
        get admin_metrics_usage_path
        ai_stats = assigns(:ai_stats)

        expect(ai_stats).to have_key(:total_today)
        expect(ai_stats).to have_key(:total_this_week)
        expect(ai_stats).to have_key(:total_this_month)
      end

      it "calculates estimated AI costs" do
        get admin_metrics_usage_path
        expect(assigns(:estimated_cost_this_month)).to be > 0
      end

      it "shows suggestions over time" do
        get admin_metrics_usage_path
        expect(assigns(:suggestions_over_time)).to be_a(Hash)
      end

      it "shows top contexts" do
        get admin_metrics_usage_path
        expect(assigns(:top_contexts)).to be_a(Hash)
      end

      it "shows ad impression metrics" do
        get admin_metrics_usage_path
        expect(assigns(:ad_impressions_this_month)).to eq(20)
      end

      it "calculates ad revenue" do
        get admin_metrics_usage_path
        expect(assigns(:ad_revenue_this_month)).to be >= 0
      end
    end

    context "when user is not an admin" do
      before { sign_in regular_user }

      it "redirects to root path" do
        get admin_metrics_usage_path
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
