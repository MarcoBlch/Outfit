# frozen_string_literal: true

# Health check controller for Railway deployment monitoring
# Provides both simple and detailed health checks
class HealthController < ActionController::Base
  # Skip CSRF for health checks (authenticate_user! not needed since we inherit from Base, not ApplicationController)
  skip_before_action :verify_authenticity_token

  # Simple health check - returns 200 if app is running
  # Railway can use this for basic uptime monitoring
  def show
    render json: { status: "ok", timestamp: Time.current.iso8601 }, status: :ok
  end

  # Detailed health check - verifies database connectivity
  # Use this for more thorough monitoring
  def detailed
    checks = {
      timestamp: Time.current.iso8601,
      environment: Rails.env,
      rails_version: Rails.version,
      ruby_version: RUBY_VERSION
    }

    # Check database connectivity
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      checks[:database] = "ok"
    rescue StandardError => e
      checks[:database] = "error"
      checks[:database_error] = e.message
      return render json: { status: "error", checks: checks }, status: :service_unavailable
    end

    # Check schema version
    begin
      version = ActiveRecord::Base.connection.select_value(
        "SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 1"
      )
      checks[:schema_version] = version
    rescue StandardError => e
      checks[:schema_version_error] = e.message
    end

    # Check if we can query the database
    begin
      checks[:user_count] = User.count
      checks[:data_access] = "ok"
    rescue StandardError => e
      checks[:data_access] = "error"
      checks[:data_access_error] = e.message
      return render json: { status: "error", checks: checks }, status: :service_unavailable
    end

    render json: { status: "ok", checks: checks }, status: :ok
  end

  # Readiness check - verifies app is ready to serve traffic
  # Railway can use this to know when the app is fully initialized
  def ready
    ready_checks = {}

    # Check database is accessible
    begin
      ActiveRecord::Base.connection.execute("SELECT 1")
      ready_checks[:database] = true
    rescue StandardError
      ready_checks[:database] = false
      return render json: { ready: false, checks: ready_checks }, status: :service_unavailable
    end

    # Check essential tables exist
    begin
      essential_tables = %w[users wardrobe_items outfits]
      missing_tables = essential_tables.reject do |table|
        ActiveRecord::Base.connection.table_exists?(table)
      end

      if missing_tables.any?
        ready_checks[:tables] = false
        ready_checks[:missing_tables] = missing_tables
        return render json: { ready: false, checks: ready_checks }, status: :service_unavailable
      else
        ready_checks[:tables] = true
      end
    rescue StandardError => e
      ready_checks[:tables] = false
      ready_checks[:error] = e.message
      return render json: { ready: false, checks: ready_checks }, status: :service_unavailable
    end

    render json: { ready: true, checks: ready_checks }, status: :ok
  end

  # Liveness check - verifies app is alive (not stuck/deadlocked)
  # Railway can use this to restart the app if it's unresponsive
  def live
    render json: { alive: true, timestamp: Time.current.iso8601 }, status: :ok
  end
end
