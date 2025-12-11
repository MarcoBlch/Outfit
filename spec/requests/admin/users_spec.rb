require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe "GET /admin/users" do
    context "when user is an admin" do
      before do
        sign_in admin_user
        create_list(:user, 10)
        create_list(:user, 5, :premium)
        create_list(:user, 3, :pro)
      end

      it "returns http success" do
        get admin_users_path
        expect(response).to have_http_status(:success)
      end

      it "displays list of users" do
        get admin_users_path
        expect(assigns(:users)).to be_present
      end

      it "filters by subscription tier" do
        get admin_users_path, params: { tier: "premium" }
        expect(assigns(:users).count).to eq(5)
      end

      it "filters by pro tier" do
        get admin_users_path, params: { tier: "pro" }
        expect(assigns(:users).count).to eq(3)
      end

      it "searches by email" do
        user = create(:user, email: "test@example.com")
        get admin_users_path, params: { search: "test@example" }
        expect(assigns(:users)).to include(user)
      end

      it "paginates results" do
        get admin_users_path
        expect(assigns(:users).current_page).to eq(1)
        expect(assigns(:users).limit_value).to eq(50)
      end

      it "filters by date range" do
        old_user = create(:user, created_at: 2.months.ago)
        recent_user = create(:user, created_at: 1.day.ago)

        get admin_users_path, params: { from_date: 1.week.ago.to_date }
        expect(assigns(:users)).to include(recent_user)
        expect(assigns(:users)).not_to include(old_user)
      end
    end

    context "when user is not an admin" do
      before { sign_in regular_user }

      it "redirects to root path with access denied message" do
        get admin_users_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Access denied")
      end
    end
  end

  describe "GET /admin/users/:id" do
    let(:target_user) { create(:user, :premium) }

    context "when user is an admin" do
      before do
        sign_in admin_user
        create_list(:outfit_suggestion, 3, user: target_user)
        create_list(:wardrobe_item, 5, user: target_user)
        create_list(:outfit, 2, user: target_user)
      end

      it "returns http success" do
        get admin_user_path(target_user)
        expect(response).to have_http_status(:success)
      end

      it "displays user details" do
        get admin_user_path(target_user)
        expect(response.body).to include(target_user.email)
      end

      it "shows wardrobe items count" do
        get admin_user_path(target_user)
        expect(assigns(:wardrobe_items_count)).to eq(5)
      end

      it "shows outfits count" do
        get admin_user_path(target_user)
        expect(assigns(:outfits_count)).to eq(2)
      end

      it "shows suggestions count" do
        get admin_user_path(target_user)
        expect(assigns(:suggestions_count)).to eq(3)
      end
    end

    context "when user is not an admin" do
      before { sign_in regular_user }

      it "redirects to root path" do
        get admin_user_path(target_user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /admin/users/:id/update_tier" do
    let(:target_user) { create(:user, subscription_tier: "free") }

    context "when user is an admin" do
      before { sign_in admin_user }

      it "updates user to premium tier" do
        patch update_tier_admin_user_path(target_user), params: { tier: "premium" }
        expect(target_user.reload.subscription_tier).to eq("premium")
      end

      it "updates user to pro tier" do
        patch update_tier_admin_user_path(target_user), params: { tier: "pro" }
        expect(target_user.reload.subscription_tier).to eq("pro")
      end

      it "redirects back to user show page" do
        patch update_tier_admin_user_path(target_user), params: { tier: "premium" }
        expect(response).to redirect_to(admin_user_path(target_user))
      end

      it "displays success message" do
        patch update_tier_admin_user_path(target_user), params: { tier: "premium" }
        follow_redirect!
        expect(response.body).to include("Tier updated")
      end

      it "rejects invalid tier" do
        patch update_tier_admin_user_path(target_user), params: { tier: "invalid" }
        expect(response).to redirect_to(admin_user_path(target_user))
        follow_redirect!
        expect(response.body).to include("Invalid tier")
      end

      it "does not change tier for invalid tier" do
        patch update_tier_admin_user_path(target_user), params: { tier: "invalid" }
        expect(target_user.reload.subscription_tier).to eq("free")
      end
    end

    context "when user is not an admin" do
      before { sign_in regular_user }

      it "redirects to root path" do
        patch update_tier_admin_user_path(target_user), params: { tier: "premium" }
        expect(response).to redirect_to(root_path)
      end

      it "does not update the tier" do
        patch update_tier_admin_user_path(target_user), params: { tier: "premium" }
        expect(target_user.reload.subscription_tier).to eq("free")
      end
    end
  end
end
