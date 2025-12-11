require 'rails_helper'

RSpec.describe "Admin::Dashboard", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe "GET /admin" do
    context "when user is an admin" do
      before do
        sign_in admin_user
        create_list(:user, 3, :premium)
        create_list(:user, 2, :pro)
        create_list(:outfit_suggestion, 5, user: admin_user)
      end

      it "returns http success" do
        get admin_root_path
        expect(response).to have_http_status(:success)
      end

      it "displays total user count" do
        get admin_root_path
        expect(response.body).to include("Total Users")
      end

      it "displays MRR metrics" do
        get admin_root_path
        expect(response.body).to include("MRR")
      end

      it "loads subscription metrics" do
        get admin_root_path
        expect(assigns(:subscription_metrics)).to be_a(Analytics::SubscriptionMetrics)
      end

      it "loads usage metrics" do
        get admin_root_path
        expect(assigns(:usage_metrics)).to be_a(Analytics::UsageMetrics)
      end

      it "calculates correct user tier breakdown" do
        get admin_root_path
        users_by_tier = assigns(:users_by_tier)

        expect(users_by_tier[:premium]).to eq(3)
        expect(users_by_tier[:pro]).to eq(2)
        expect(users_by_tier[:free]).to be >= 1 # At least the admin user
      end
    end

    context "when user is not an admin" do
      before { sign_in regular_user }

      it "redirects to root path" do
        get admin_root_path
        expect(response).to redirect_to(root_path)
      end

      it "displays access denied message" do
        get admin_root_path
        follow_redirect!
        expect(response.body).to include("Access denied")
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in page" do
        get admin_root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
