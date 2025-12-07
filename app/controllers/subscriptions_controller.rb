class SubscriptionsController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]
  skip_before_action :verify_authenticity_token, only: [:webhook], raise: false

  # GET /subscriptions/new - Pricing page
  def new
    @current_subscription = current_user.subscription
  end

  # POST /subscriptions - Create checkout session
  def create
    # Check if user already has active subscription
    if current_user.premium?
      redirect_to root_path, alert: "You already have an active subscription."
      return
    end

    # Find or create Stripe customer
    customer_id = find_or_create_stripe_customer

    # Create Stripe checkout session
    session = Stripe::Checkout::Session.create(
      customer: customer_id,
      payment_method_types: ["card"],
      line_items: [{
        price: ENV["STRIPE_PREMIUM_PRICE_ID"],
        quantity: 1
      }],
      mode: "subscription",
      success_url: success_subscriptions_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: cancel_subscriptions_url,
      metadata: {
        user_id: current_user.id
      }
    )

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe checkout error: #{e.message}")
    redirect_to new_subscription_path, alert: "Unable to start checkout. Please try again."
  end

  # GET /subscriptions/success
  def success
    session_id = params[:session_id]
    return redirect_to root_path unless session_id.present?

    # Verify the session
    session = Stripe::Checkout::Session.retrieve(session_id)

    if session.customer == current_user.subscription&.stripe_customer_id ||
       session.metadata.user_id == current_user.id.to_s
      flash[:notice] = "Welcome to Premium! Your subscription is now active."
    end

    redirect_to root_path
  rescue Stripe::StripeError => e
    Rails.logger.error("Stripe session verification error: #{e.message}")
    redirect_to root_path, notice: "Your subscription has been processed."
  end

  # GET /subscriptions/cancel
  def cancel
    redirect_to new_subscription_path, notice: "Subscription checkout was cancelled."
  end

  # POST /subscriptions/webhook
  def webhook
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      Rails.logger.error("Webhook JSON parse error: #{e.message}")
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error("Webhook signature verification failed: #{e.message}")
      return head :bad_request
    end

    # Handle the event
    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    when "customer.subscription.updated"
      handle_subscription_updated(event.data.object)
    when "customer.subscription.deleted"
      handle_subscription_deleted(event.data.object)
    when "invoice.payment_failed"
      handle_payment_failed(event.data.object)
    else
      Rails.logger.info("Unhandled Stripe event type: #{event.type}")
    end

    head :ok
  end

  # POST /subscriptions/cancel_subscription
  def cancel_subscription
    subscription = current_user.subscription

    unless subscription&.active_subscription?
      redirect_to new_subscription_path, alert: "No active subscription to cancel."
      return
    end

    # Cancel at period end (user keeps access until then)
    Stripe::Subscription.update(
      subscription.stripe_subscription_id,
      { cancel_at_period_end: true }
    )

    subscription.update!(cancel_at_period_end: true)

    redirect_to new_subscription_path, notice: "Your subscription will be cancelled at the end of the billing period."
  rescue Stripe::StripeError => e
    Rails.logger.error("Subscription cancellation error: #{e.message}")
    redirect_to new_subscription_path, alert: "Unable to cancel subscription. Please try again."
  end

  # POST /subscriptions/reactivate
  def reactivate
    subscription = current_user.subscription

    unless subscription&.cancel_at_period_end?
      redirect_to new_subscription_path, alert: "No cancelled subscription to reactivate."
      return
    end

    Stripe::Subscription.update(
      subscription.stripe_subscription_id,
      { cancel_at_period_end: false }
    )

    subscription.update!(cancel_at_period_end: false)

    redirect_to new_subscription_path, notice: "Your subscription has been reactivated!"
  rescue Stripe::StripeError => e
    Rails.logger.error("Subscription reactivation error: #{e.message}")
    redirect_to new_subscription_path, alert: "Unable to reactivate subscription. Please try again."
  end

  # GET /subscriptions/portal
  def portal
    subscription = current_user.subscription

    unless subscription&.stripe_customer_id.present?
      redirect_to new_subscription_path, alert: "No billing information available."
      return
    end

    session = Stripe::BillingPortal::Session.create(
      customer: subscription.stripe_customer_id,
      return_url: new_subscription_path
    )

    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error("Billing portal error: #{e.message}")
    redirect_to new_subscription_path, alert: "Unable to access billing portal. Please try again."
  end

  private

  def find_or_create_stripe_customer
    existing_subscription = current_user.subscription

    if existing_subscription&.stripe_customer_id.present?
      return existing_subscription.stripe_customer_id
    end

    customer = Stripe::Customer.create(
      email: current_user.email,
      metadata: { user_id: current_user.id }
    )

    # Store customer ID for future use
    if existing_subscription
      existing_subscription.update!(stripe_customer_id: customer.id)
    else
      Subscription.create!(
        user: current_user,
        stripe_customer_id: customer.id,
        status: :incomplete
      )
    end

    customer.id
  end

  def handle_checkout_completed(session)
    user_id = session.metadata.user_id
    user = User.find_by(id: user_id)
    return unless user

    # Retrieve the subscription
    stripe_subscription = Stripe::Subscription.retrieve(session.subscription)

    subscription = user.subscription || user.build_subscription
    subscription.update!(
      stripe_subscription_id: stripe_subscription.id,
      stripe_customer_id: session.customer,
      stripe_price_id: stripe_subscription.items.data.first.price.id,
      status: stripe_subscription.status,
      current_period_start: Time.zone.at(stripe_subscription.current_period_start),
      current_period_end: Time.zone.at(stripe_subscription.current_period_end),
      cancel_at_period_end: false
    )

    # Update user tier
    user.update!(subscription_tier: "premium")

    Rails.logger.info("Subscription created for user #{user_id}")
  end

  def handle_subscription_updated(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(
      status: stripe_subscription.status,
      current_period_start: Time.zone.at(stripe_subscription.current_period_start),
      current_period_end: Time.zone.at(stripe_subscription.current_period_end),
      cancel_at_period_end: stripe_subscription.cancel_at_period_end
    )

    # Update user tier based on status
    new_tier = stripe_subscription.status == "active" ? "premium" : "free"
    subscription.user.update!(subscription_tier: new_tier)

    Rails.logger.info("Subscription #{subscription.id} updated to #{stripe_subscription.status}")
  end

  def handle_subscription_deleted(stripe_subscription)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_subscription.id)
    return unless subscription

    subscription.update!(status: :canceled)
    subscription.user.update!(subscription_tier: "free")

    Rails.logger.info("Subscription #{subscription.id} cancelled")
  end

  def handle_payment_failed(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: :past_due)

    Rails.logger.warn("Payment failed for subscription #{subscription.id}")
  end
end
