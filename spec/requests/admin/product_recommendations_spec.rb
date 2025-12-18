require 'rails_helper'

RSpec.describe "Admin::ProductRecommendations", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe "GET /admin/product_recommendations" do
    context "when user is an admin" do
      before do
        sign_in admin_user
        # Create some test data
        @user = create(:user)
        @outfit_suggestion1 = create(:outfit_suggestion, user: @user)
        @outfit_suggestion2 = create(:outfit_suggestion, user: @user)

        # Create recommendations with different priorities and analytics
        @high_priority_rec = create(:product_recommendation,
                                    outfit_suggestion: @outfit_suggestion1,
                                    category: 'tops',
                                    priority: :high,
                                    views: 100,
                                    clicks: 10,
                                    conversions: 2,
                                    revenue_earned: 50.00)

        @medium_priority_rec = create(:product_recommendation,
                                      outfit_suggestion: @outfit_suggestion1,
                                      category: 'bottoms',
                                      priority: :medium,
                                      views: 200,
                                      clicks: 5,
                                      conversions: 0,
                                      revenue_earned: 0.00)

        @low_priority_rec = create(:product_recommendation,
                                   outfit_suggestion: @outfit_suggestion2,
                                   category: 'shoes',
                                   priority: :low,
                                   views: 50,
                                   clicks: 3,
                                   conversions: 1,
                                   revenue_earned: 100.00)

        # Create one with high CTR
        @high_ctr_rec = create(:product_recommendation,
                               outfit_suggestion: @outfit_suggestion2,
                               category: 'accessories',
                               priority: :high,
                               views: 100,
                               clicks: 15,
                               conversions: 5,
                               revenue_earned: 200.00)
      end

      it "returns http success" do
        get admin_product_recommendations_path
        expect(response).to have_http_status(:success)
      end

      it "displays list of recommendations" do
        get admin_product_recommendations_path
        expect(assigns(:recommendations)).to be_present
        expect(assigns(:recommendations).count).to eq(4)
      end

      it "calculates aggregate statistics correctly" do
        get admin_product_recommendations_path
        expect(assigns(:total_views)).to eq(450)
        expect(assigns(:total_clicks)).to eq(33)
        expect(assigns(:total_conversions)).to eq(8)
        expect(assigns(:total_revenue)).to eq(350.00)
        expect(assigns(:avg_ctr)).to eq(7.33) # 33/450 * 100 = 7.33
      end

      describe "filtering" do
        it "filters by priority" do
          get admin_product_recommendations_path, params: { priority: "high" }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations.count).to eq(2)
          expect(recommendations).to include(@high_priority_rec, @high_ctr_rec)
        end

        it "filters by category" do
          get admin_product_recommendations_path, params: { category: "tops" }
          expect(assigns(:recommendations).count).to eq(1)
          expect(assigns(:recommendations).first).to eq(@high_priority_rec)
        end

        it "filters by outfit suggestion" do
          get admin_product_recommendations_path, params: { outfit_suggestion_id: @outfit_suggestion1.id }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations.count).to eq(2)
          expect(recommendations).to include(@high_priority_rec, @medium_priority_rec)
        end

        it "filters by high CTR performance (>5%)" do
          get admin_product_recommendations_path, params: { performance: "high_ctr" }
          recommendations = assigns(:recommendations).to_a
          # high_priority_rec: 10%, high_ctr_rec: 15%, low_priority_rec: 6%
          expect(recommendations.count).to eq(3)
        end

        it "filters by high revenue performance (>$50)" do
          get admin_product_recommendations_path, params: { performance: "high_revenue" }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations.count).to eq(2)
          expect(recommendations).to include(@low_priority_rec, @high_ctr_rec)
        end

        it "filters by high conversion performance (>10%)" do
          get admin_product_recommendations_path, params: { performance: "high_conversion" }
          recommendations = assigns(:recommendations).to_a
          # high_priority_rec: 20%, high_ctr_rec: 33.33%, low_priority_rec: 33.33%
          expect(recommendations.count).to eq(3)
        end

        it "filters by date range" do
          old_rec = create(:product_recommendation,
                          outfit_suggestion: @outfit_suggestion1,
                          created_at: 2.months.ago)
          recent_rec = create(:product_recommendation,
                             outfit_suggestion: @outfit_suggestion1,
                             created_at: 1.day.ago)

          get admin_product_recommendations_path, params: { from_date: 1.week.ago.to_date }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations).to include(recent_rec)
          expect(recommendations).not_to include(old_rec)
        end
      end

      describe "sorting" do
        it "sorts by views descending" do
          get admin_product_recommendations_path, params: { sort: "views_desc" }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations.first).to eq(@medium_priority_rec) # 200 views
        end

        it "sorts by clicks descending" do
          get admin_product_recommendations_path, params: { sort: "clicks_desc" }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations.first).to eq(@high_ctr_rec) # 15 clicks
        end

        it "sorts by revenue descending" do
          get admin_product_recommendations_path, params: { sort: "revenue_desc" }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations.first).to eq(@high_ctr_rec) # $200
        end

        it "sorts by CTR descending" do
          get admin_product_recommendations_path, params: { sort: "ctr_desc" }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations.first).to eq(@high_ctr_rec) # 15% CTR
        end

        it "sorts by created date ascending" do
          get admin_product_recommendations_path, params: { sort: "created_asc" }
          recommendations = assigns(:recommendations).to_a
          expect(recommendations.first.created_at).to be <= recommendations.last.created_at
        end
      end

      it "paginates results" do
        get admin_product_recommendations_path
        expect(assigns(:recommendations).current_page).to eq(1)
        expect(assigns(:recommendations).limit_value).to eq(50)
      end

      describe "CSV export" do
        it "generates CSV file" do
          get admin_product_recommendations_path(format: :csv)
          expect(response).to have_http_status(:success)
          expect(response.content_type).to include('text/csv')
        end

        it "includes correct headers in CSV" do
          get admin_product_recommendations_path(format: :csv)
          csv_content = response.body
          expect(csv_content).to include('ID')
          expect(csv_content).to include('Category')
          expect(csv_content).to include('Priority')
          expect(csv_content).to include('Views')
          expect(csv_content).to include('Clicks')
          expect(csv_content).to include('CTR %')
          expect(csv_content).to include('Revenue')
        end

        it "includes recommendation data in CSV" do
          get admin_product_recommendations_path(format: :csv)
          csv_content = response.body
          expect(csv_content).to include(@high_priority_rec.category)
          expect(csv_content).to include(@high_priority_rec.priority)
        end

        it "respects filters when exporting" do
          get admin_product_recommendations_path(format: :csv, params: { priority: "high" })
          csv_content = response.body
          # Should only include high priority recommendations
          expect(csv_content).to include('high')
          # Count lines (excluding header)
          lines = csv_content.lines.count
          expect(lines).to eq(3) # 1 header + 2 high priority recommendations
        end
      end
    end

    context "when user is not an admin" do
      before { sign_in regular_user }

      it "redirects to root path with access denied message" do
        get admin_product_recommendations_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include("Access denied")
      end

      it "does not allow CSV export" do
        get admin_product_recommendations_path(format: :csv)
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in page" do
        get admin_product_recommendations_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "analytics calculations" do
    before do
      sign_in admin_user
      @user = create(:user)
      @outfit_suggestion = create(:outfit_suggestion, user: @user)
    end

    it "handles zero views correctly" do
      create(:product_recommendation,
             outfit_suggestion: @outfit_suggestion,
             views: 0,
             clicks: 0,
             conversions: 0)

      get admin_product_recommendations_path
      expect(assigns(:avg_ctr)).to eq(0.0)
    end

    it "handles zero clicks correctly" do
      create(:product_recommendation,
             outfit_suggestion: @outfit_suggestion,
             views: 100,
             clicks: 0,
             conversions: 0)

      get admin_product_recommendations_path
      expect(assigns(:avg_ctr)).to eq(0.0)
      expect(assigns(:avg_conversion_rate)).to eq(0.0)
    end

    it "handles zero conversions correctly" do
      create(:product_recommendation,
             outfit_suggestion: @outfit_suggestion,
             views: 100,
             clicks: 10,
             conversions: 0)

      get admin_product_recommendations_path
      expect(assigns(:avg_conversion_rate)).to eq(0.0)
      expect(assigns(:avg_revenue_per_conversion)).to eq(0.0)
    end

    it "calculates metrics with mixed data" do
      create(:product_recommendation,
             outfit_suggestion: @outfit_suggestion,
             views: 100,
             clicks: 10,
             conversions: 2,
             revenue_earned: 50.00)

      create(:product_recommendation,
             outfit_suggestion: @outfit_suggestion,
             views: 0,
             clicks: 0,
             conversions: 0,
             revenue_earned: 0.00)

      get admin_product_recommendations_path
      expect(assigns(:total_views)).to eq(100)
      expect(assigns(:total_clicks)).to eq(10)
      expect(assigns(:avg_ctr)).to eq(10.0) # 10/100 * 100
    end
  end
end
