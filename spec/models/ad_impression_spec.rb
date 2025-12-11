require 'rails_helper'

RSpec.describe AdImpression, type: :model do
  let(:user) { create(:user) }

  describe "associations" do
    it "belongs to user" do
      ad_impression = AdImpression.new(user: user, placement: "dashboard_banner")
      expect(ad_impression.user).to eq(user)
    end
  end

  describe "validations" do
    it "validates presence of placement" do
      ad_impression = AdImpression.new(user: user, placement: nil)
      expect(ad_impression).not_to be_valid
      expect(ad_impression.errors[:placement]).to include("can't be blank")
    end

    it "validates inclusion of placement" do
      ad_impression = AdImpression.new(user: user, placement: "invalid")
      expect(ad_impression).not_to be_valid
      expect(ad_impression.errors[:placement]).to include("is not included in the list")
    end

    it "accepts valid placements" do
      %w[dashboard_banner wardrobe_grid outfit_modal].each do |placement|
        ad_impression = AdImpression.new(user: user, placement: placement)
        ad_impression.valid?
        expect(ad_impression.errors[:placement]).to be_empty
      end
    end

    it "validates numericality of revenue" do
      ad_impression = AdImpression.new(user: user, placement: "dashboard_banner", revenue: -1)
      expect(ad_impression).not_to be_valid
      expect(ad_impression.errors[:revenue]).to include("must be greater than or equal to 0")
    end
  end

  describe "scopes" do
    before do
      create(:ad_impression, user: user, created_at: Time.current)
      create(:ad_impression, user: user, created_at: 5.days.ago)
      create(:ad_impression, user: user, created_at: 2.weeks.ago)
      create(:ad_impression, user: user, created_at: 2.months.ago)
    end

    describe ".today" do
      it "returns impressions from today" do
        expect(AdImpression.today.count).to eq(1)
      end
    end

    describe ".this_week" do
      it "returns impressions from this week" do
        expect(AdImpression.this_week.count).to eq(2)
      end
    end

    describe ".this_month" do
      it "returns impressions from this month" do
        expect(AdImpression.this_month.count).to eq(3)
      end
    end

    describe ".clicked" do
      before do
        create(:ad_impression, user: user, clicked: true)
        create(:ad_impression, user: user, clicked: false)
      end

      it "returns only clicked impressions" do
        expect(AdImpression.clicked.count).to eq(1)
      end
    end

    describe ".by_placement" do
      before do
        create_list(:ad_impression, 3, user: user, placement: "dashboard_banner")
        create_list(:ad_impression, 2, user: user, placement: "wardrobe_grid")
      end

      it "filters by placement" do
        expect(AdImpression.by_placement("dashboard_banner").count).to eq(3)
        expect(AdImpression.by_placement("wardrobe_grid").count).to eq(2)
      end
    end
  end

  describe ".estimated_revenue_today" do
    before do
      create(:ad_impression, user: user, revenue: 0.05, created_at: Time.current)
      create(:ad_impression, user: user, revenue: 0.03, created_at: Time.current)
      create(:ad_impression, user: user, revenue: 0.10, created_at: 2.days.ago)
    end

    it "sums revenue for today only" do
      expect(AdImpression.estimated_revenue_today).to eq(0.08)
    end
  end

  describe ".estimated_revenue_this_month" do
    before do
      create(:ad_impression, user: user, revenue: 0.05, created_at: Time.current)
      create(:ad_impression, user: user, revenue: 0.03, created_at: 2.weeks.ago)
      create(:ad_impression, user: user, revenue: 0.10, created_at: 2.months.ago)
    end

    it "sums revenue for this month only" do
      expect(AdImpression.estimated_revenue_this_month).to eq(0.08)
    end
  end

  describe ".click_through_rate" do
    context "with impressions and clicks" do
      before do
        create_list(:ad_impression, 8, user: user, clicked: false, created_at: Time.current)
        create_list(:ad_impression, 2, user: user, clicked: true, created_at: Time.current)
      end

      it "calculates CTR correctly" do
        expect(AdImpression.click_through_rate(:today)).to eq(20.0)
      end
    end

    context "with no impressions" do
      it "returns zero" do
        expect(AdImpression.click_through_rate(:today)).to eq(0)
      end
    end
  end

  describe ".revenue_by_placement" do
    before do
      create(:ad_impression, user: user, placement: "dashboard_banner", revenue: 0.10)
      create(:ad_impression, user: user, placement: "dashboard_banner", revenue: 0.05)
      create(:ad_impression, user: user, placement: "wardrobe_grid", revenue: 0.03)
    end

    it "groups revenue by placement" do
      result = AdImpression.revenue_by_placement

      expect(result["dashboard_banner"]).to eq(0.15)
      expect(result["wardrobe_grid"]).to eq(0.03)
    end
  end

  describe ".impressions_by_day" do
    before do
      create(:ad_impression, user: user, created_at: 2.days.ago)
      create(:ad_impression, user: user, created_at: 2.days.ago)
      create(:ad_impression, user: user, created_at: 5.days.ago)
    end

    it "groups impressions by day" do
      result = AdImpression.impressions_by_day(30)
      expect(result).to be_a(Hash)
      expect(result.values.sum).to eq(3)
    end
  end
end
