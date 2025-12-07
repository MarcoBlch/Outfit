Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

# Configure Stripe API version for consistency
Stripe.api_version = "2024-12-18.acacia"

# Enable idempotency for webhook handling
Stripe.max_network_retries = 2
