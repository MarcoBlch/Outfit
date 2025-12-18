module Admin
  class ProductRecommendationsController < Admin::BaseController
    def index
      # Base query with eager loading to prevent N+1 queries
      @recommendations = ProductRecommendation
                          .includes(:outfit_suggestion)
                          .order(created_at: :desc)

      # Apply filters
      @recommendations = apply_filters(@recommendations)

      # Apply sorting
      @recommendations = apply_sorting(@recommendations)

      # Calculate aggregate statistics before pagination
      calculate_aggregate_stats

      # Pagination
      @recommendations = @recommendations.page(params[:page]).per(50)

      # Handle CSV export
      respond_to do |format|
        format.html
        format.csv do
          csv_data = generate_csv
          send_data csv_data,
                    filename: "product_recommendations_#{Date.current}.csv",
                    type: 'text/csv'
        end
      end
    end

    private

    def apply_filters(scope)
      # Filter by outfit suggestion
      if params[:outfit_suggestion_id].present?
        scope = scope.where(outfit_suggestion_id: params[:outfit_suggestion_id])
      end

      # Filter by priority
      if params[:priority].present? && params[:priority] != "all"
        scope = scope.where(priority: params[:priority])
      end

      # Filter by category
      if params[:category].present? && params[:category] != "all"
        scope = scope.where(category: params[:category])
      end

      # Filter by date range
      if params[:from_date].present?
        scope = scope.where("product_recommendations.created_at >= ?", params[:from_date])
      end

      if params[:to_date].present?
        scope = scope.where("product_recommendations.created_at <= ?", params[:to_date].to_date.end_of_day)
      end

      # Filter by performance
      case params[:performance]
      when "high_ctr"
        # CTR > 5%
        scope = scope.where("views > 0").where("CAST(clicks AS FLOAT) / NULLIF(views, 0) > 0.05")
      when "high_revenue"
        # Revenue > $50
        scope = scope.where("revenue_earned > 50")
      when "high_conversion"
        # Conversion rate > 10%
        scope = scope.where("clicks > 0").where("CAST(conversions AS FLOAT) / NULLIF(clicks, 0) > 0.10")
      when "with_images"
        scope = scope.with_images
      when "with_products"
        scope = scope.with_products
      end

      scope
    end

    def apply_sorting(scope)
      case params[:sort]
      when "views_desc"
        scope.reorder(views: :desc)
      when "views_asc"
        scope.reorder(views: :asc)
      when "clicks_desc"
        scope.reorder(clicks: :desc)
      when "clicks_asc"
        scope.reorder(clicks: :asc)
      when "revenue_desc"
        scope.reorder(Arel.sql("revenue_earned DESC NULLS LAST"))
      when "revenue_asc"
        scope.reorder(Arel.sql("revenue_earned ASC NULLS LAST"))
      when "ctr_desc"
        scope.where("views > 0").reorder(Arel.sql("CAST(clicks AS FLOAT) / NULLIF(views, 0) DESC"))
      when "ctr_asc"
        scope.where("views > 0").reorder(Arel.sql("CAST(clicks AS FLOAT) / NULLIF(views, 0) ASC"))
      when "conversion_desc"
        scope.where("clicks > 0").reorder(Arel.sql("CAST(conversions AS FLOAT) / NULLIF(clicks, 0) DESC"))
      when "conversion_asc"
        scope.where("clicks > 0").reorder(Arel.sql("CAST(conversions AS FLOAT) / NULLIF(clicks, 0) ASC"))
      when "created_desc"
        scope.reorder(created_at: :desc)
      when "created_asc"
        scope.reorder(created_at: :asc)
      else
        scope # Don't reorder if no sort param, keep default order from line 7
      end
    end

    def calculate_aggregate_stats
      # Use the filtered scope for stats (before pagination)
      filtered_scope = @recommendations

      @total_views = filtered_scope.sum(:views)
      @total_clicks = filtered_scope.sum(:clicks)
      @total_conversions = filtered_scope.sum(:conversions)
      @total_revenue = filtered_scope.sum(:revenue_earned) || 0.0

      # Calculate average CTR
      @avg_ctr = if @total_views > 0
                   (@total_clicks.to_f / @total_views * 100).round(2)
                 else
                   0.0
                 end

      # Calculate average conversion rate
      @avg_conversion_rate = if @total_clicks > 0
                              (@total_conversions.to_f / @total_clicks * 100).round(2)
                            else
                              0.0
                            end

      # Calculate average revenue per conversion
      @avg_revenue_per_conversion = if @total_conversions > 0
                                      (@total_revenue / @total_conversions).round(2)
                                    else
                                      0.0
                                    end

      # Total count
      @total_count = filtered_scope.count
    end

    def generate_csv
      require 'csv'

      CSV.generate(headers: true) do |csv|
        # Headers
        csv << [
          'ID',
          'Outfit Suggestion ID',
          'Category',
          'Priority',
          'Views',
          'Clicks',
          'CTR %',
          'Conversions',
          'Conversion Rate %',
          'Revenue',
          'Avg Revenue per Conversion',
          'Products Count',
          'AI Image Status',
          'Created At'
        ]

        # Data rows
        apply_filters(ProductRecommendation.includes(:outfit_suggestion).order(created_at: :desc)).find_each do |rec|
          csv << [
            rec.id,
            rec.outfit_suggestion_id,
            rec.category,
            rec.priority,
            rec.views,
            rec.clicks,
            rec.ctr,
            rec.conversions,
            rec.conversion_rate,
            rec.revenue_earned || 0.0,
            rec.avg_revenue_per_conversion,
            rec.products_count,
            rec.ai_image_status,
            rec.created_at.iso8601
          ]
        end
      end
    end
  end
end
