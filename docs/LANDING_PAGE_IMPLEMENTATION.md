# Landing Page Implementation Guide

Complete guide to creating a proper landing page (no login wall) for OutfitMaker.ai.

---

## The Problem

**Current state:** Visitors land on `/` and immediately see login form (authentication wall)

**What we need:** Visitors land on `/` and see:
- Hero section with value proposition
- Demo video showing the app
- Clear benefits
- Social proof (testimonials)
- Strong CTA to sign up

---

## Part 1: Create Landing Page Controller (15 minutes)

### Step 1: Generate Controller

```bash
rails generate controller Landing index
```

This creates:
- `app/controllers/landing_controller.rb`
- `app/views/landing/index.html.erb`

### Step 2: Configure Routes

**File:** `config/routes.rb`

```ruby
Rails.application.routes.draw do
  # Landing page (unauthenticated)
  root to: 'landing#index'

  # Authenticated app (after login)
  authenticated :user do
    root to: 'pages#home', as: :authenticated_root
  end

  # Devise routes
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # ... rest of your routes ...
end
```

**How this works:**
- Logged out users → `landing#index` (marketing page)
- Logged in users → `pages#home` (dashboard)

### Step 3: Update Landing Controller

**File:** `app/controllers/landing_controller.rb`

```ruby
class LandingController < ApplicationController
  # Skip authentication for landing page
  skip_before_action :authenticate_user!, only: [:index]

  def index
    # Redirect to dashboard if already logged in
    if user_signed_in?
      redirect_to authenticated_root_path
    end
  end
end
```

---

## Part 2: Create Landing Page HTML (60 minutes)

**File:** `app/views/landing/index.html.erb`

```erb
<!-- Hero Section -->
<div class="relative overflow-hidden bg-gradient-to-br from-purple-600 via-pink-600 to-orange-500 pb-32">
  <!-- Navigation -->
  <nav class="relative z-10 bg-transparent">
    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
      <div class="flex h-16 items-center justify-between">
        <!-- Logo -->
        <div class="flex items-center">
          <span class="text-2xl font-bold text-white">OutfitMaker.ai</span>
        </div>

        <!-- Nav Links -->
        <div class="hidden md:flex items-center space-x-8">
          <a href="#features" class="text-white/90 hover:text-white transition">Features</a>
          <a href="#how-it-works" class="text-white/90 hover:text-white transition">How It Works</a>
          <a href="#pricing" class="text-white/90 hover:text-white transition">Pricing</a>
          <%= link_to "Sign In", new_user_session_path, class: "text-white/90 hover:text-white transition" %>
          <%= link_to "Start Free Trial", new_user_registration_path, class: "px-4 py-2 bg-white text-purple-600 font-semibold rounded-lg hover:bg-purple-50 transition" %>
        </div>

        <!-- Mobile menu button -->
        <div class="md:hidden">
          <button type="button" class="text-white" data-controller="mobile-menu" data-action="click->mobile-menu#toggle">
            <svg class="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
            </svg>
          </button>
        </div>
      </div>
    </div>
  </nav>

  <!-- Hero Content -->
  <div class="relative z-10 mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 pt-20 pb-16 text-center">
    <!-- Badge -->
    <div class="inline-flex items-center rounded-full bg-white/10 px-4 py-2 text-sm text-white backdrop-blur-sm mb-8">
      <span class="mr-2">✨</span>
      <span>Join 500+ users styling smarter with AI</span>
    </div>

    <!-- Headline -->
    <h1 class="text-5xl md:text-7xl font-bold text-white mb-6 leading-tight">
      Your AI Wardrobe<br>
      Stylist + Personal<br>
      <span class="bg-clip-text text-transparent bg-gradient-to-r from-yellow-200 to-pink-200">Shopper</span>
    </h1>

    <!-- Subheadline -->
    <p class="text-xl md:text-2xl text-white/90 mb-10 max-w-2xl mx-auto">
      Get AI outfit suggestions from your wardrobe + shop the missing pieces to complete your look.
    </p>

    <!-- CTA Buttons -->
    <div class="flex flex-col sm:flex-row gap-4 justify-center items-center">
      <%= link_to new_user_registration_path, class: "px-8 py-4 bg-white text-purple-600 font-bold text-lg rounded-xl hover:bg-purple-50 shadow-2xl transition-all hover:scale-105" do %>
        Start Free Trial
        <span class="ml-2">→</span>
      <% end %>

      <button class="px-8 py-4 bg-white/10 text-white font-semibold text-lg rounded-xl hover:bg-white/20 backdrop-blur-sm transition" data-action="click->video#play">
        <span class="mr-2">▶</span>
        Watch Demo (30s)
      </button>
    </div>

    <!-- Trust Signals -->
    <div class="mt-12 flex flex-wrap justify-center items-center gap-6 text-white/70 text-sm">
      <div class="flex items-center">
        <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-11a1 1 0 10-2 0v3.586L7.707 9.293a1 1 0 00-1.414 1.414l3 3a1 1 0 001.414 0l3-3a1 1 0 00-1.414-1.414L11 10.586V7z"/>
        </svg>
        <span>No credit card required</span>
      </div>
      <div class="flex items-center">
        <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"/>
        </svg>
        <span>7-day free trial</span>
      </div>
      <div class="flex items-center">
        <svg class="w-5 h-5 mr-2" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 3.5a1.5 1.5 0 013 0V4a1 1 0 001 1h3a1 1 0 011 1v3a1 1 0 01-1 1h-.5a1.5 1.5 0 000 3h.5a1 1 0 011 1v3a1 1 0 01-1 1h-3a1 1 0 01-1-1v-.5a1.5 1.5 0 00-3 0v.5a1 1 0 01-1 1H6a1 1 0 01-1-1v-3a1 1 0 00-1-1h-.5a1.5 1.5 0 010-3H4a1 1 0 001-1V6a1 1 0 011-1h3a1 1 0 001-1v-.5z"/>
        </svg>
        <span>Works on iPhone & Android</span>
      </div>
    </div>
  </div>

  <!-- Decorative blur circles -->
  <div class="absolute top-0 right-0 w-96 h-96 bg-white/10 rounded-full blur-3xl"></div>
  <div class="absolute bottom-0 left-0 w-96 h-96 bg-yellow-400/10 rounded-full blur-3xl"></div>
</div>

<!-- Demo Video Modal (hidden by default) -->
<div id="video-modal" class="hidden fixed inset-0 z-50 bg-black/80 flex items-center justify-center" data-controller="video-modal">
  <div class="relative w-full max-w-4xl mx-4">
    <button class="absolute -top-12 right-0 text-white text-4xl" data-action="click->video-modal#close">&times;</button>
    <div class="relative pt-[56.25%]">
      <iframe
        class="absolute inset-0 w-full h-full rounded-lg"
        src="https://www.youtube.com/embed/YOUR_VIDEO_ID"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen>
      </iframe>
    </div>
  </div>
</div>

<!-- Social Proof Section -->
<section class="py-16 bg-white">
  <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-12">
      <h2 class="text-3xl font-bold text-gray-900 mb-4">Loved by fashion-conscious people everywhere</h2>
      <p class="text-gray-600">See what our users are saying</p>
    </div>

    <!-- Testimonials Grid -->
    <div class="grid md:grid-cols-3 gap-8">
      <!-- Testimonial 1 -->
      <div class="bg-gray-50 p-6 rounded-xl">
        <div class="flex items-center mb-4">
          <div class="flex text-yellow-400">
            ★★★★★
          </div>
        </div>
        <p class="text-gray-700 mb-4 italic">
          "I saved 2 hours getting ready this week! The AI suggestions are spot-on."
        </p>
        <div class="flex items-center">
          <div class="w-10 h-10 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full mr-3"></div>
          <div>
            <p class="font-semibold text-gray-900">Sarah M.</p>
            <p class="text-sm text-gray-500">Premium user</p>
          </div>
        </div>
      </div>

      <!-- Testimonial 2 -->
      <div class="bg-gray-50 p-6 rounded-xl">
        <div class="flex items-center mb-4">
          <div class="flex text-yellow-400">
            ★★★★★
          </div>
        </div>
        <p class="text-gray-700 mb-4 italic">
          "The shopping feature is genius. I bought ONE cardigan and now have 12 new outfits."
        </p>
        <div class="flex items-center">
          <div class="w-10 h-10 bg-gradient-to-br from-blue-400 to-green-400 rounded-full mr-3"></div>
          <div>
            <p class="font-semibold text-gray-900">Tom R.</p>
            <p class="text-sm text-gray-500">Premium user</p>
          </div>
        </div>
      </div>

      <!-- Testimonial 3 -->
      <div class="bg-gray-50 p-6 rounded-xl">
        <div class="flex items-center mb-4">
          <div class="flex text-yellow-400">
            ★★★★★
          </div>
        </div>
        <p class="text-gray-700 mb-4 italic">
          "AI suggested an outfit with my leopard print scarf I forgot I owned. It was perfect!"
        </p>
        <div class="flex items-center">
          <div class="w-10 h-10 bg-gradient-to-br from-pink-400 to-orange-400 rounded-full mr-3"></div>
          <div>
            <p class="font-semibold text-gray-900">Michelle K.</p>
            <p class="text-sm text-gray-500">Pro user</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- Features Section -->
<section id="features" class="py-20 bg-gray-50">
  <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h2 class="text-4xl font-bold text-gray-900 mb-4">Everything you need to look great</h2>
      <p class="text-xl text-gray-600">Powered by the latest AI technology</p>
    </div>

    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
      <!-- Feature 1: AI Outfit Suggestions -->
      <div class="bg-white p-8 rounded-2xl shadow-sm hover:shadow-lg transition">
        <div class="w-14 h-14 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center mb-6">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
          </svg>
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">AI Outfit Suggestions</h3>
        <p class="text-gray-600">
          Get personalized outfit combinations from your wardrobe in seconds. Perfect for any occasion.
        </p>
      </div>

      <!-- Feature 2: Complete Your Look -->
      <div class="bg-white p-8 rounded-2xl shadow-sm hover:shadow-lg transition">
        <div class="w-14 h-14 bg-gradient-to-br from-pink-500 to-orange-500 rounded-xl flex items-center justify-center mb-6">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"></path>
          </svg>
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">Complete Your Look</h3>
        <p class="text-gray-600">
          AI identifies missing pieces and shows you exactly what to buy to complete your wardrobe.
        </p>
      </div>

      <!-- Feature 3: Smart Wardrobe -->
      <div class="bg-white p-8 rounded-2xl shadow-sm hover:shadow-lg transition">
        <div class="w-14 h-14 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-xl flex items-center justify-center mb-6">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
          </svg>
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">Smart Wardrobe</h3>
        <p class="text-gray-600">
          Organize your clothes digitally. AI auto-tags categories, colors, and styles automatically.
        </p>
      </div>

      <!-- Feature 4: Weather Aware -->
      <div class="bg-white p-8 rounded-2xl shadow-sm hover:shadow-lg transition">
        <div class="w-14 h-14 bg-gradient-to-br from-yellow-500 to-orange-500 rounded-xl flex items-center justify-center mb-6">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z"></path>
          </svg>
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">Weather Aware</h3>
        <p class="text-gray-600">
          Get outfit suggestions that match the weather. Never be caught unprepared again.
        </p>
      </div>

      <!-- Feature 5: Style Analytics -->
      <div class="bg-white p-8 rounded-2xl shadow-sm hover:shadow-lg transition">
        <div class="w-14 h-14 bg-gradient-to-br from-green-500 to-teal-500 rounded-xl flex items-center justify-center mb-6">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 00 2-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
          </svg>
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">Style Analytics</h3>
        <p class="text-gray-600">
          Track your most-worn items, cost-per-wear, and wardrobe trends over time.
        </p>
      </div>

      <!-- Feature 6: Mobile PWA -->
      <div class="bg-white p-8 rounded-2xl shadow-sm hover:shadow-lg transition">
        <div class="w-14 h-14 bg-gradient-to-br from-purple-500 to-blue-500 rounded-xl flex items-center justify-center mb-6">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
          </svg>
        </div>
        <h3 class="text-xl font-bold text-gray-900 mb-3">Works Like an App</h3>
        <p class="text-gray-600">
          Install on your phone's home screen. Works offline and feels like a native app.
        </p>
      </div>
    </div>
  </div>
</section>

<!-- How It Works Section -->
<section id="how-it-works" class="py-20 bg-white">
  <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h2 class="text-4xl font-bold text-gray-900 mb-4">How it works</h2>
      <p class="text-xl text-gray-600">Get started in 3 simple steps</p>
    </div>

    <div class="grid md:grid-cols-3 gap-12">
      <!-- Step 1 -->
      <div class="text-center">
        <div class="w-16 h-16 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-6">
          1
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Upload Your Wardrobe</h3>
        <p class="text-gray-600 text-lg">
          Take photos of your clothes. AI automatically categorizes and tags everything.
        </p>
      </div>

      <!-- Step 2 -->
      <div class="text-center">
        <div class="w-16 h-16 bg-gradient-to-br from-pink-500 to-orange-500 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-6">
          2
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Get AI Suggestions</h3>
        <p class="text-gray-600 text-lg">
          Tell us the occasion. AI creates 3 perfect outfit combinations in seconds.
        </p>
      </div>

      <!-- Step 3 -->
      <div class="text-center">
        <div class="w-16 h-16 bg-gradient-to-br from-orange-500 to-yellow-500 rounded-full flex items-center justify-center text-white text-2xl font-bold mx-auto mb-6">
          3
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-4">Shop Missing Pieces</h3>
        <p class="text-gray-600 text-lg">
          AI shows you exactly what to buy to complete your look. Shop smart, not more.
        </p>
      </div>
    </div>

    <!-- CTA -->
    <div class="text-center mt-16">
      <%= link_to new_user_registration_path, class: "inline-flex items-center px-8 py-4 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold text-lg rounded-xl hover:shadow-2xl transition-all hover:scale-105" do %>
        Start Your Free Trial
        <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
        </svg>
      <% end %>
      <p class="mt-4 text-gray-500 text-sm">No credit card required • 7-day free trial</p>
    </div>
  </div>
</section>

<!-- Pricing Section -->
<section id="pricing" class="py-20 bg-gray-50">
  <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h2 class="text-4xl font-bold text-gray-900 mb-4">Simple, transparent pricing</h2>
      <p class="text-xl text-gray-600">Start free, upgrade when you're ready</p>
    </div>

    <div class="grid md:grid-cols-3 gap-8 max-w-6xl mx-auto">
      <!-- Free Tier -->
      <div class="bg-white p-8 rounded-2xl shadow-sm border border-gray-200">
        <h3 class="text-2xl font-bold text-gray-900 mb-2">Free</h3>
        <p class="text-gray-600 mb-6">Perfect for trying it out</p>
        <div class="mb-8">
          <span class="text-5xl font-bold text-gray-900">€0</span>
          <span class="text-gray-500">/month</span>
        </div>
        <ul class="space-y-4 mb-8">
          <li class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">50 wardrobe items</span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">3 AI suggestions/day</span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">Shopping recommendations</span>
          </li>
        </ul>
        <%= link_to "Start Free", new_user_registration_path, class: "block w-full text-center py-3 px-6 bg-gray-100 text-gray-900 font-semibold rounded-lg hover:bg-gray-200 transition" %>
      </div>

      <!-- Premium Tier (Most Popular) -->
      <div class="bg-white p-8 rounded-2xl shadow-xl border-2 border-purple-500 relative">
        <div class="absolute -top-4 left-1/2 -translate-x-1/2 bg-gradient-to-r from-purple-600 to-pink-600 text-white px-4 py-1 rounded-full text-sm font-semibold">
          Most Popular
        </div>
        <h3 class="text-2xl font-bold text-gray-900 mb-2">Premium</h3>
        <p class="text-gray-600 mb-6">For serious stylists</p>
        <div class="mb-8">
          <span class="text-5xl font-bold text-gray-900">€7.99</span>
          <span class="text-gray-500">/month</span>
        </div>
        <ul class="space-y-4 mb-8">
          <li class="flex items-start">
            <svg class="w-6 h-6 text-purple-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700"><strong>300 wardrobe items</strong></span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-purple-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700"><strong>30 suggestions/day</strong></span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-purple-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">AI auto-tagging</span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-purple-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">Weather integration</span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-purple-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">Priority support</span>
          </li>
        </ul>
        <%= link_to "Start 7-Day Trial", new_user_registration_path, class: "block w-full text-center py-3 px-6 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold rounded-lg hover:shadow-xl transition-all hover:scale-105" %>
      </div>

      <!-- Pro Tier -->
      <div class="bg-white p-8 rounded-2xl shadow-sm border border-gray-200">
        <h3 class="text-2xl font-bold text-gray-900 mb-2">Pro</h3>
        <p class="text-gray-600 mb-6">For power users</p>
        <div class="mb-8">
          <span class="text-5xl font-bold text-gray-900">€14.99</span>
          <span class="text-gray-500">/month</span>
        </div>
        <ul class="space-y-4 mb-8">
          <li class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700"><strong>Unlimited everything</strong></span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">Virtual try-on (coming soon)</span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">Exclusive brand deals</span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">Advanced analytics</span>
          </li>
          <li class="flex items-start">
            <svg class="w-6 h-6 text-green-500 mr-3 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-gray-700">White-label sharing</span>
          </li>
        </ul>
        <%= link_to "Start 7-Day Trial", new_user_registration_path, class: "block w-full text-center py-3 px-6 bg-gray-900 text-white font-semibold rounded-lg hover:bg-gray-800 transition" %>
      </div>
    </div>
  </div>
</section>

<!-- FAQ Section -->
<section class="py-20 bg-white">
  <div class="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
    <div class="text-center mb-16">
      <h2 class="text-4xl font-bold text-gray-900 mb-4">Frequently asked questions</h2>
    </div>

    <div class="space-y-6">
      <!-- FAQ 1 -->
      <details class="group bg-gray-50 rounded-lg p-6">
        <summary class="flex justify-between items-center font-semibold text-gray-900 cursor-pointer list-none">
          <span>How does the AI work?</span>
          <span class="transition group-open:rotate-180">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </span>
        </summary>
        <p class="text-gray-600 mt-4">
          Our AI is powered by Google's Gemini 2.5 Flash, trained on millions of fashion images. It analyzes your wardrobe items (colors, styles, categories) and creates outfit combinations that work together. It considers the occasion, weather, and your personal style preferences.
        </p>
      </details>

      <!-- FAQ 2 -->
      <details class="group bg-gray-50 rounded-lg p-6">
        <summary class="flex justify-between items-center font-semibold text-gray-900 cursor-pointer list-none">
          <span>Is my data private?</span>
          <span class="transition group-open:rotate-180">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </span>
        </summary>
        <p class="text-gray-600 mt-4">
          Yes! Your photos are stored securely and never shared with third parties. We use industry-standard encryption. You can delete your account and all data anytime.
        </p>
      </details>

      <!-- FAQ 3 -->
      <details class="group bg-gray-50 rounded-lg p-6">
        <summary class="flex justify-between items-center font-semibold text-gray-900 cursor-pointer list-none">
          <span>Can I cancel anytime?</span>
          <span class="transition group-open:rotate-180">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </span>
        </summary>
        <p class="text-gray-600 mt-4">
          Absolutely! You can cancel your subscription anytime from your account settings. No questions asked, no hidden fees. You'll keep access until the end of your billing period.
        </p>
      </details>

      <!-- FAQ 4 -->
      <details class="group bg-gray-50 rounded-lg p-6">
        <summary class="flex justify-between items-center font-semibold text-gray-900 cursor-pointer list-none">
          <span>Does it work on mobile?</span>
          <span class="transition group-open:rotate-180">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </span>
        </summary>
        <p class="text-gray-600 mt-4">
          Yes! OutfitMaker.ai is a Progressive Web App (PWA). It works on iPhone and Android, and you can install it on your home screen like a native app. No app store needed.
        </p>
      </details>

      <!-- FAQ 5 -->
      <details class="group bg-gray-50 rounded-lg p-6">
        <summary class="flex justify-between items-center font-semibold text-gray-900 cursor-pointer list-none">
          <span>What if I don't like the suggestions?</span>
          <span class="transition group-open:rotate-180">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
            </svg>
          </span>
        </summary>
        <p class="text-gray-600 mt-4">
          You can regenerate suggestions instantly or adjust your style preferences in settings. The AI learns from your feedback, so it gets better over time. Plus, you have a 7-day free trial to test it risk-free!
        </p>
      </details>
    </div>
  </div>
</section>

<!-- Final CTA Section -->
<section class="py-20 bg-gradient-to-br from-purple-600 via-pink-600 to-orange-500 relative overflow-hidden">
  <div class="relative z-10 mx-auto max-w-4xl px-4 sm:px-6 lg:px-8 text-center">
    <h2 class="text-4xl md:text-5xl font-bold text-white mb-6">
      Ready to transform your wardrobe?
    </h2>
    <p class="text-xl text-white/90 mb-10">
      Join 500+ users who never have to ask "What should I wear?" again.
    </p>
    <%= link_to new_user_registration_path, class: "inline-flex items-center px-10 py-5 bg-white text-purple-600 font-bold text-xl rounded-xl hover:bg-purple-50 shadow-2xl transition-all hover:scale-105" do %>
      Start Your Free Trial
      <svg class="w-6 h-6 ml-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
      </svg>
    <% end %>
    <p class="mt-6 text-white/80 text-sm">No credit card required • 7-day free trial • Cancel anytime</p>
  </div>

  <!-- Decorative elements -->
  <div class="absolute top-0 left-0 w-96 h-96 bg-yellow-400/20 rounded-full blur-3xl"></div>
  <div class="absolute bottom-0 right-0 w-96 h-96 bg-pink-400/20 rounded-full blur-3xl"></div>
</section>

<!-- Footer -->
<footer class="bg-gray-900 text-white py-12">
  <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
    <div class="grid md:grid-cols-4 gap-8">
      <!-- Column 1: Brand -->
      <div>
        <h3 class="text-2xl font-bold mb-4">OutfitMaker.ai</h3>
        <p class="text-gray-400">Your AI wardrobe stylist + personal shopper.</p>
      </div>

      <!-- Column 2: Product -->
      <div>
        <h4 class="font-semibold mb-4">Product</h4>
        <ul class="space-y-2 text-gray-400">
          <li><a href="#features" class="hover:text-white transition">Features</a></li>
          <li><a href="#how-it-works" class="hover:text-white transition">How It Works</a></li>
          <li><a href="#pricing" class="hover:text-white transition">Pricing</a></li>
        </ul>
      </div>

      <!-- Column 3: Company -->
      <div>
        <h4 class="font-semibold mb-4">Company</h4>
        <ul class="space-y-2 text-gray-400">
          <li><a href="/about" class="hover:text-white transition">About</a></li>
          <li><a href="/blog" class="hover:text-white transition">Blog</a></li>
          <li><a href="/contact" class="hover:text-white transition">Contact</a></li>
        </ul>
      </div>

      <!-- Column 4: Legal -->
      <div>
        <h4 class="font-semibold mb-4">Legal</h4>
        <ul class="space-y-2 text-gray-400">
          <li><a href="/privacy" class="hover:text-white transition">Privacy Policy</a></li>
          <li><a href="/terms" class="hover:text-white transition">Terms of Service</a></li>
        </ul>
      </div>
    </div>

    <div class="border-t border-gray-800 mt-12 pt-8 text-center text-gray-400 text-sm">
      <p>© 2026 OutfitMaker.ai. All rights reserved.</p>
    </div>
  </div>
</footer>
```

---

## Part 3: Add Stimulus Controllers for Interactions (30 minutes)

The landing page has interactive elements (video modal, mobile menu). Let's add Stimulus controllers.

**File:** `app/javascript/controllers/video_modal_controller.js` (create this)

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    // Listen for video play button clicks
    document.querySelectorAll('[data-action*="video#play"]').forEach(button => {
      button.addEventListener('click', this.open.bind(this))
    })
  }

  open(event) {
    event.preventDefault()
    const modal = document.getElementById('video-modal')
    if (modal) {
      modal.classList.remove('hidden')
    }
  }

  close(event) {
    event.preventDefault()
    const modal = document.getElementById('video-modal')
    if (modal) {
      modal.classList.add('hidden')
      // Stop video playback
      const iframe = modal.querySelector('iframe')
      if (iframe) {
        const src = iframe.src
        iframe.src = ''
        iframe.src = src
      }
    }
  }

  // Close on escape key
  disconnect() {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.close(e)
      }
    })
  }
}
```

---

## Part 4: Deploy & Test (15 minutes)

1. **Commit changes:**
```bash
git add .
git commit -m "feat: Add landing page (no login wall)"
git push
```

2. **Deploy to Railway:**
```bash
railway up
```

3. **Test it:**
- Visit `outfitmaker.ai` (not logged in)
- You should see the new landing page!
- Click "Start Free Trial" → Goes to signup
- After login → Goes to dashboard

---

## Part 5: Optimize for Mobile (Ongoing)

Use Chrome DevTools:
1. Open landing page
2. Press F12 → Toggle device toolbar
3. Test on iPhone SE, iPhone 12 Pro, iPad
4. Check:
   - Text readable?
   - Buttons thumb-sized (44x44px minimum)?
   - Images load fast?
   - Horizontal scroll? (should be none)

---

## Next Steps

Once landing page is live:
1. Record 30-second demo video (screen recording)
2. Upload to YouTube
3. Replace `YOUR_VIDEO_ID` in video modal
4. Get testimonials from beta testers
5. Replace placeholder testimonials with real ones

---

**Questions?** Deploy the landing page and test it. Let me know what needs fixing!