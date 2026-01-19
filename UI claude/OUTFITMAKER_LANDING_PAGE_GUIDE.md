# OutfitMaker.ai Landing Page - Complete Design System & Component Library

## 🎨 Design Philosophy

**Inspiration Sources:**
- Modern AI SaaS landing pages (Rizzle, Claude, Midjourney aesthetic)
- Codia AI dark theme (dark cards, purple/indigo accents)
- Fashion-forward design (elegant, clean, sophisticated)

**Core Principles:**
1. **Bold Hero** - Large headline, gradient text, 3D elements
2. **Dark Mode First** - Dark backgrounds with vibrant accents
3. **Glass Morphism** - Subtle transparency and blur effects
4. **Smooth Animations** - Subtle hover effects and transitions
5. **Trust Signals** - Social proof, testimonials, stats
6. **Mobile Optimized** - Responsive from 320px to 4K

---

## 🌈 Color System

### Primary Palette
```css
/* Gradients */
--gradient-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
--gradient-secondary: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
--gradient-accent: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
--gradient-warm: linear-gradient(135deg, #fa709a 0%, #fee140 100%);

/* Solid Colors */
--purple-500: #8B5CF6;
--purple-600: #7C3AED;
--purple-700: #6D28D9;
--indigo-500: #6366F1;
--indigo-600: #4F46E5;
--pink-500: #EC4899;
--pink-600: #DB2777;

/* Dark Theme */
--bg-dark: #0F0F0F;
--bg-card: #1A1A1B;
--bg-card-hover: #242526;
--border-dark: #2A2A2C;
--text-primary: #FFFFFF;
--text-secondary: #A0A0A3;
--text-muted: #6B6B6E;
```

### Tailwind Config
```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        outfit: {
          bg: '#0F0F0F',
          card: '#1A1A1B',
          'card-hover': '#242526',
          border: '#2A2A2C',
        }
      },
      backgroundImage: {
        'gradient-primary': 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        'gradient-secondary': 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
        'gradient-accent': 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
        'gradient-radial': 'radial-gradient(circle at center, var(--tw-gradient-stops))',
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'gradient': 'gradient 8s linear infinite',
        'glow': 'glow 2s ease-in-out infinite alternate',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%': { transform: 'translateY(-20px)' },
        },
        gradient: {
          '0%, 100%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
        },
        glow: {
          'from': { boxShadow: '0 0 20px rgba(139, 92, 246, 0.5)' },
          'to': { boxShadow: '0 0 40px rgba(139, 92, 246, 0.8)' },
        },
      },
    },
  },
}
```

---

## 📐 Landing Page Structure

```
┌─────────────────────────────────────┐
│ 1. Navigation                       │
├─────────────────────────────────────┤
│ 2. Hero Section                     │
│    - Main headline                  │
│    - Subheadline                    │
│    - CTA buttons                    │
│    - Hero visual (mockup/3D)        │
├─────────────────────────────────────┤
│ 3. Social Proof                     │
│    - User stats                     │
│    - Logo cloud                     │
├─────────────────────────────────────┤
│ 4. Features Grid                    │
│    - 3 columns                      │
│    - Icons + descriptions           │
├─────────────────────────────────────┤
│ 5. Product Demo                     │
│    - Large screenshot/video         │
│    - Feature callouts               │
├─────────────────────────────────────┤
│ 6. How It Works                     │
│    - 3 step process                 │
│    - Visual timeline                │
├─────────────────────────────────────┤
│ 7. Testimonials                     │
│    - User quotes                    │
│    - Profile photos                 │
├─────────────────────────────────────┤
│ 8. Pricing (Optional for Beta)     │
│    - 3 tiers                        │
│    - Feature comparison             │
├─────────────────────────────────────┤
│ 9. Final CTA                        │
│    - Join waitlist/Start free       │
├─────────────────────────────────────┤
│ 10. Footer                          │
│    - Links, social, legal           │
└─────────────────────────────────────┘
```

---

## 🧩 Component Library

### 1. Navigation Bar

```erb
<!-- app/views/layouts/_landing_nav.html.erb -->
<nav class="fixed top-0 left-0 right-0 z-50 bg-outfit-bg/80 backdrop-blur-lg border-b border-outfit-border">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex items-center justify-between h-16">
      <!-- Logo -->
      <%= link_to root_path, class: "flex items-center space-x-2 group" do %>
        <div class="w-10 h-10 bg-gradient-primary rounded-xl flex items-center justify-center group-hover:scale-105 transition-transform">
          <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" />
          </svg>
        </div>
        <span class="text-xl font-bold bg-gradient-primary bg-clip-text text-transparent">
          OutfitMaker.ai
        </span>
      <% end %>

      <!-- Desktop Navigation -->
      <div class="hidden md:flex items-center space-x-8">
        <%= link_to 'Features', '#features', class: 'text-text-secondary hover:text-text-primary transition-colors' %>
        <%= link_to 'How It Works', '#how-it-works', class: 'text-text-secondary hover:text-text-primary transition-colors' %>
        <%= link_to 'Pricing', '#pricing', class: 'text-text-secondary hover:text-text-primary transition-colors' %>
        <%= link_to 'Blog', '#', class: 'text-text-secondary hover:text-text-primary transition-colors' %>
      </div>

      <!-- CTA Buttons -->
      <div class="flex items-center space-x-4">
        <%= link_to 'Sign In', new_user_session_path, class: 'hidden sm:block text-text-secondary hover:text-text-primary transition-colors' %>
        <%= link_to new_user_registration_path, class: 'btn-primary' do %>
          Start Free Trial
          <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
          </svg>
        <% end %>
      </div>

      <!-- Mobile Menu Button -->
      <button type="button" class="md:hidden p-2 text-text-secondary" data-action="click->mobile-menu#toggle">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>
    </div>
  </div>

  <!-- Mobile Menu (hidden by default) -->
  <div class="md:hidden hidden" data-mobile-menu-target="menu">
    <div class="px-4 pt-2 pb-4 space-y-2 bg-outfit-card border-t border-outfit-border">
      <%= link_to 'Features', '#features', class: 'block py-2 text-text-secondary hover:text-text-primary' %>
      <%= link_to 'How It Works', '#how-it-works', class: 'block py-2 text-text-secondary hover:text-text-primary' %>
      <%= link_to 'Pricing', '#pricing', class: 'block py-2 text-text-secondary hover:text-text-primary' %>
      <%= link_to 'Blog', '#', class: 'block py-2 text-text-secondary hover:text-text-primary' %>
      <div class="pt-4 space-y-2">
        <%= link_to 'Sign In', new_user_session_path, class: 'block py-2 text-center text-text-secondary' %>
        <%= link_to 'Start Free Trial', new_user_registration_path, class: 'block btn-primary text-center' %>
      </div>
    </div>
  </div>
</nav>
```

---

### 2. Hero Section

```erb
<!-- app/views/landing/_hero.html.erb -->
<section class="relative min-h-screen flex items-center justify-center overflow-hidden bg-outfit-bg">
  <!-- Animated Background -->
  <div class="absolute inset-0">
    <!-- Gradient Orbs -->
    <div class="absolute top-0 -left-4 w-96 h-96 bg-purple-500/20 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-float"></div>
    <div class="absolute top-0 -right-4 w-96 h-96 bg-pink-500/20 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-float" style="animation-delay: 2s;"></div>
    <div class="absolute -bottom-8 left-20 w-96 h-96 bg-indigo-500/20 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-float" style="animation-delay: 4s;"></div>
    
    <!-- Grid Pattern -->
    <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+PGRlZnM+PHBhdHRlcm4gaWQ9ImdyaWQiIHdpZHRoPSI2MCIgaGVpZ2h0PSI2MCIgcGF0dGVyblVuaXRzPSJ1c2VyU3BhY2VPblVzZSI+PHBhdGggZD0iTSAxMCAwIEwgMCAwIDAgMTAiIGZpbGw9Im5vbmUiIHN0cm9rZT0iIzJBMkEyQyIgc3Ryb2tlLXdpZHRoPSIxIi8+PC9wYXR0ZXJuPjwvZGVmcz48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSJ1cmwoI2dyaWQpIi8+PC9zdmc+')] opacity-20"></div>
  </div>

  <!-- Content -->
  <div class="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
    <div class="grid lg:grid-cols-2 gap-12 items-center">
      <!-- Left Column: Text Content -->
      <div class="text-center lg:text-left">
        <!-- Badge -->
        <div class="inline-flex items-center px-4 py-2 rounded-full bg-purple-500/10 border border-purple-500/20 mb-8">
          <span class="w-2 h-2 bg-purple-500 rounded-full animate-pulse mr-2"></span>
          <span class="text-sm text-purple-300">AI-Powered Wardrobe Assistant</span>
        </div>

        <!-- Main Headline -->
        <h1 class="text-5xl sm:text-6xl lg:text-7xl font-bold leading-tight mb-6">
          <span class="text-white">Your Wardrobe,</span><br/>
          <span class="bg-gradient-primary bg-clip-text text-transparent bg-[length:200%_200%] animate-gradient">
            Organized by AI
          </span>
        </h1>

        <!-- Subheadline -->
        <p class="text-xl text-text-secondary mb-8 max-w-2xl">
          Never wonder "what to wear" again. OutfitMaker.ai uses advanced AI to curate perfect outfits from your existing wardrobe.
        </p>

        <!-- CTA Buttons -->
        <div class="flex flex-col sm:flex-row gap-4 justify-center lg:justify-start mb-12">
          <%= link_to new_user_registration_path, class: 'btn-primary btn-lg group' do %>
            Start Free Trial
            <svg class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
            </svg>
          <% end %>
          <%= link_to '#demo', class: 'btn-secondary btn-lg group' do %>
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Watch Demo
          <% end %>
        </div>

        <!-- Social Proof -->
        <div class="flex items-center gap-8 justify-center lg:justify-start text-sm text-text-muted">
          <div class="flex items-center">
            <div class="flex -space-x-2">
              <% 5.times do %>
                <div class="w-8 h-8 rounded-full bg-gradient-to-br from-purple-400 to-pink-400 border-2 border-outfit-bg"></div>
              <% end %>
            </div>
            <span class="ml-3">10,000+ users</span>
          </div>
          <div class="flex items-center">
            <svg class="w-5 h-5 text-yellow-400 mr-1" fill="currentColor" viewBox="0 0 20 20">
              <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
            </svg>
            <span>4.9/5 rating</span>
          </div>
        </div>
      </div>

      <!-- Right Column: Hero Visual -->
      <div class="relative lg:h-[600px]">
        <!-- Phone Mockup Container -->
        <div class="relative mx-auto w-full max-w-sm">
          <!-- Glass Card with App Preview -->
          <div class="relative bg-outfit-card/40 backdrop-blur-xl rounded-3xl border border-white/10 p-8 shadow-2xl animate-float">
            <!-- Mockup Content - Replace with actual app screenshot -->
            <div class="aspect-[9/16] bg-gradient-to-br from-purple-500/20 to-pink-500/20 rounded-2xl border border-white/10 overflow-hidden">
              <!-- This would be your actual app screenshot -->
              <div class="h-full flex flex-col p-6">
                <div class="flex-1 space-y-4">
                  <div class="h-12 bg-white/10 rounded-lg"></div>
                  <div class="grid grid-cols-2 gap-4">
                    <div class="aspect-square bg-white/10 rounded-lg"></div>
                    <div class="aspect-square bg-white/10 rounded-lg"></div>
                    <div class="aspect-square bg-white/10 rounded-lg"></div>
                    <div class="aspect-square bg-white/10 rounded-lg"></div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Floating Elements -->
            <div class="absolute -top-4 -right-4 bg-green-500 text-white px-4 py-2 rounded-full text-sm font-medium shadow-lg">
              ✨ AI Powered
            </div>
            <div class="absolute -bottom-4 -left-4 bg-pink-500 text-white px-4 py-2 rounded-full text-sm font-medium shadow-lg">
              🎨 Perfect Matches
            </div>
          </div>

          <!-- Decorative Elements -->
          <div class="absolute top-1/4 -right-8 w-32 h-32 bg-purple-500/20 rounded-full blur-2xl"></div>
          <div class="absolute bottom-1/4 -left-8 w-32 h-32 bg-pink-500/20 rounded-full blur-2xl"></div>
        </div>
      </div>
    </div>
  </div>

  <!-- Scroll Indicator -->
  <div class="absolute bottom-8 left-1/2 -translate-x-1/2 animate-bounce">
    <svg class="w-6 h-6 text-text-muted" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 14l-7 7m0 0l-7-7m7 7V3" />
    </svg>
  </div>
</section>
```

---

### 3. Social Proof Section

```erb
<!-- app/views/landing/_social_proof.html.erb -->
<section class="py-16 bg-outfit-card/30 border-y border-outfit-border">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Stats Grid -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-8 text-center">
      <div>
        <div class="text-4xl font-bold bg-gradient-primary bg-clip-text text-transparent mb-2">
          10K+
        </div>
        <div class="text-sm text-text-muted">Active Users</div>
      </div>
      <div>
        <div class="text-4xl font-bold bg-gradient-secondary bg-clip-text text-transparent mb-2">
          500K+
        </div>
        <div class="text-sm text-text-muted">Outfits Created</div>
      </div>
      <div>
        <div class="text-4xl font-bold bg-gradient-accent bg-clip-text text-transparent mb-2">
          98%
        </div>
        <div class="text-sm text-text-muted">Satisfaction Rate</div>
      </div>
      <div>
        <div class="text-4xl font-bold bg-gradient-warm bg-clip-text text-transparent mb-2">
          4.9★
        </div>
        <div class="text-sm text-text-muted">App Store Rating</div>
      </div>
    </div>

    <!-- Logo Cloud (Optional - if you have partnerships) -->
    <!-- 
    <div class="mt-16">
      <p class="text-center text-sm text-text-muted mb-8">Featured in</p>
      <div class="flex flex-wrap justify-center items-center gap-12 opacity-50">
        <!- Logo SVGs here ->
      </div>
    </div>
    -->
  </div>
</section>
```

---

### 4. Features Grid

```erb
<!-- app/views/landing/_features.html.erb -->
<section id="features" class="py-24 bg-outfit-bg">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Section Header -->
    <div class="text-center mb-16">
      <h2 class="text-4xl sm:text-5xl font-bold text-white mb-4">
        Everything you need to look your best
      </h2>
      <p class="text-xl text-text-secondary max-w-2xl mx-auto">
        Powered by advanced AI that understands your style and helps you make the most of your wardrobe.
      </p>
    </div>

    <!-- Features Grid -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
      <!-- Feature Card Template -->
      <%= render 'landing/feature_card',
        icon: 'camera',
        gradient: 'from-purple-500 to-pink-500',
        title: 'Smart Photo Capture',
        description: 'Snap a photo of any clothing item. Our AI automatically removes backgrounds and tags items by category, color, and style.' %>

      <%= render 'landing/feature_card',
        icon: 'sparkles',
        gradient: 'from-indigo-500 to-purple-500',
        title: 'AI Outfit Suggestions',
        description: 'Get personalized outfit recommendations based on weather, occasion, and your personal style preferences.' %>

      <%= render 'landing/feature_card',
        icon: 'search',
        gradient: 'from-pink-500 to-red-500',
        title: 'Visual Search',
        description: 'Find similar items in your wardrobe or discover shopping suggestions to complete your look.' %>

      <%= render 'landing/feature_card',
        icon: 'palette',
        gradient: 'from-blue-500 to-cyan-500',
        title: 'Style Quiz',
        description: 'Take our quick style quiz to help our AI understand your preferences and create better suggestions.' %>

      <%= render 'landing/feature_card',
        icon: 'cloud',
        gradient: 'from-green-500 to-teal-500',
        title: 'Weather-Aware',
        description: 'Get outfit suggestions that match the current weather conditions in your location.' %>

      <%= render 'landing/feature_card',
        icon: 'shopping-bag',
        gradient: 'from-orange-500 to-yellow-500',
        title: 'Complete Your Look',
        description: 'Discover shopping suggestions on Amazon to fill gaps in your wardrobe and complete your style.' %>
    </div>
  </div>
</section>

<!-- app/views/landing/_feature_card.html.erb -->
<%
  icon_paths = {
    'camera' => 'M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z M15 13a3 3 0 11-6 0 3 3 0 016 0z',
    'sparkles' => 'M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z',
    'search' => 'M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z',
    'palette' => 'M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01',
    'cloud' => 'M3 15a4 4 0 004 4h9a5 5 0 10-.1-9.999 5.002 5.002 0 10-9.78 2.096A4.001 4.001 0 003 15z',
    'shopping-bag' => 'M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z'
  }
%>

<div class="group relative bg-outfit-card hover:bg-outfit-card-hover border border-outfit-border hover:border-white/20 rounded-2xl p-8 transition-all duration-300 hover:-translate-y-1">
  <!-- Gradient Border on Hover -->
  <div class="absolute inset-0 bg-gradient-to-r <%= gradient %> opacity-0 group-hover:opacity-10 rounded-2xl transition-opacity"></div>
  
  <!-- Icon -->
  <div class="relative w-14 h-14 bg-gradient-to-br <%= gradient %> rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
    <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" d="<%= icon_paths[icon] %>" />
    </svg>
  </div>

  <!-- Content -->
  <h3 class="text-xl font-semibold text-white mb-3"><%= title %></h3>
  <p class="text-text-secondary leading-relaxed"><%= description %></p>

  <!-- Arrow Icon -->
  <div class="mt-4 text-purple-400 opacity-0 group-hover:opacity-100 transition-opacity">
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
    </svg>
  </div>
</div>
```

---

### 5. Product Demo Section

```erb
<!-- app/views/landing/_demo.html.erb -->
<section id="demo" class="py-24 bg-gradient-to-b from-outfit-bg to-outfit-card">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="grid lg:grid-cols-2 gap-12 items-center">
      <!-- Left: Content -->
      <div>
        <div class="inline-block px-4 py-2 bg-purple-500/10 border border-purple-500/20 rounded-full text-sm text-purple-300 mb-6">
          See It In Action
        </div>
        
        <h2 class="text-4xl sm:text-5xl font-bold text-white mb-6">
          From chaos to curated in seconds
        </h2>
        
        <p class="text-xl text-text-secondary mb-8">
          Watch how OutfitMaker.ai transforms your wardrobe photos into a perfectly organized digital closet.
        </p>

        <!-- Feature List -->
        <div class="space-y-4 mb-8">
          <div class="flex items-start">
            <div class="flex-shrink-0 w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center mr-3 mt-1">
              <svg class="w-4 h-4 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <div>
              <h4 class="text-white font-medium mb-1">Automatic Background Removal</h4>
              <p class="text-text-secondary text-sm">No green screen needed. Our AI removes backgrounds instantly.</p>
            </div>
          </div>
          
          <div class="flex items-start">
            <div class="flex-shrink-0 w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center mr-3 mt-1">
              <svg class="w-4 h-4 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <div>
              <h4 class="text-white font-medium mb-1">Smart Auto-Tagging</h4>
              <p class="text-text-secondary text-sm">Categories, colors, patterns—all tagged automatically.</p>
            </div>
          </div>
          
          <div class="flex items-start">
            <div class="flex-shrink-0 w-6 h-6 bg-green-500/20 rounded-full flex items-center justify-center mr-3 mt-1">
              <svg class="w-4 h-4 text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
              </svg>
            </div>
            <div>
              <h4 class="text-white font-medium mb-1">Instant Outfit Suggestions</h4>
              <p class="text-text-secondary text-sm">Get AI-powered combinations in under 3 seconds.</p>
            </div>
          </div>
        </div>

        <%= link_to new_user_registration_path, class: 'btn-primary inline-flex items-center' do %>
          Try It Free
          <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
          </svg>
        <% end %>
      </div>

      <!-- Right: Visual/Video -->
      <div class="relative">
        <!-- Video Container or Large Screenshot -->
        <div class="relative bg-outfit-card rounded-2xl border border-outfit-border overflow-hidden shadow-2xl">
          <!-- Replace with actual video or screenshots -->
          <div class="aspect-video bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center">
            <button class="w-20 h-20 bg-white rounded-full flex items-center justify-center shadow-lg hover:scale-110 transition-transform">
              <svg class="w-10 h-10 text-purple-600 ml-1" fill="currentColor" viewBox="0 0 24 24">
                <path d="M8 5v14l11-7z" />
              </svg>
            </button>
          </div>

          <!-- Feature Callouts -->
          <div class="absolute top-4 right-4 bg-white/10 backdrop-blur-md px-3 py-2 rounded-lg border border-white/20">
            <div class="text-xs text-white font-medium">⚡ 2.3s processing time</div>
          </div>
        </div>

        <!-- Decorative Elements -->
        <div class="absolute -z-10 -top-8 -right-8 w-64 h-64 bg-purple-500/20 rounded-full blur-3xl"></div>
        <div class="absolute -z-10 -bottom-8 -left-8 w-64 h-64 bg-pink-500/20 rounded-full blur-3xl"></div>
      </div>
    </div>
  </div>
</section>
```

---

### 6. How It Works

```erb
<!-- app/views/landing/_how_it_works.html.erb -->
<section id="how-it-works" class="py-24 bg-outfit-bg">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-20">
      <h2 class="text-4xl sm:text-5xl font-bold text-white mb-4">
        Getting started is easy
      </h2>
      <p class="text-xl text-text-secondary max-w-2xl mx-auto">
        Three simple steps to your perfectly organized wardrobe
      </p>
    </div>

    <!-- Steps -->
    <div class="relative">
      <!-- Connection Line -->
      <div class="hidden lg:block absolute top-1/2 left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-purple-500/50 to-transparent -translate-y-1/2"></div>

      <div class="grid md:grid-cols-3 gap-8 relative">
        <!-- Step 1 -->
        <div class="relative">
          <div class="bg-outfit-card hover:bg-outfit-card-hover border border-outfit-border rounded-2xl p-8 transition-all duration-300 hover:-translate-y-2">
            <!-- Number Badge -->
            <div class="w-12 h-12 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center text-white font-bold text-xl mb-6 shadow-lg">
              1
            </div>

            <!-- Icon -->
            <div class="w-16 h-16 bg-purple-500/10 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-8 h-8 text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
            </div>

            <h3 class="text-2xl font-bold text-white mb-3">Snap Photos</h3>
            <p class="text-text-secondary leading-relaxed">
              Take photos of your clothes or upload existing images. No special equipment needed—your phone camera works great.
            </p>
          </div>
        </div>

        <!-- Step 2 -->
        <div class="relative">
          <div class="bg-outfit-card hover:bg-outfit-card-hover border border-outfit-border rounded-2xl p-8 transition-all duration-300 hover:-translate-y-2">
            <div class="w-12 h-12 bg-gradient-to-br from-indigo-500 to-purple-500 rounded-xl flex items-center justify-center text-white font-bold text-xl mb-6 shadow-lg">
              2
            </div>

            <div class="w-16 h-16 bg-indigo-500/10 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-8 h-8 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
              </svg>
            </div>

            <h3 class="text-2xl font-bold text-white mb-3">AI Organizes</h3>
            <p class="text-text-secondary leading-relaxed">
              Our AI automatically removes backgrounds, tags items by category, color, and style, and organizes everything beautifully.
            </p>
          </div>
        </div>

        <!-- Step 3 -->
        <div class="relative">
          <div class="bg-outfit-card hover:bg-outfit-card-hover border border-outfit-border rounded-2xl p-8 transition-all duration-300 hover:-translate-y-2">
            <div class="w-12 h-12 bg-gradient-to-br from-pink-500 to-red-500 rounded-xl flex items-center justify-center text-white font-bold text-xl mb-6 shadow-lg">
              3
            </div>

            <div class="w-16 h-16 bg-pink-500/10 rounded-xl flex items-center justify-center mb-6">
              <svg class="w-8 h-8 text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
              </svg>
            </div>

            <h3 class="text-2xl font-bold text-white mb-3">Get Outfits</h3>
            <p class="text-text-secondary leading-relaxed">
              Receive personalized outfit suggestions every day based on weather, occasion, and your unique style preferences.
            </p>
          </div>
        </div>
      </div>
    </div>

    <!-- CTA -->
    <div class="text-center mt-16">
      <%= link_to new_user_registration_path, class: 'btn-primary btn-lg inline-flex items-center' do %>
        Start Organizing Your Wardrobe
        <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
        </svg>
      <% end %>
    </div>
  </div>
</section>
```

---

### 7. Testimonials

```erb
<!-- app/views/landing/_testimonials.html.erb -->
<section class="py-24 bg-gradient-to-b from-outfit-card to-outfit-bg">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-16">
      <h2 class="text-4xl sm:text-5xl font-bold text-white mb-4">
        Loved by fashion enthusiasts
      </h2>
      <p class="text-xl text-text-secondary">
        See what our users are saying about OutfitMaker.ai
      </p>
    </div>

    <!-- Testimonials Grid -->
    <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
      <% [
        {
          name: "Sarah Johnson",
          role: "Fashion Blogger",
          avatar_color: "from-purple-400 to-pink-400",
          rating: 5,
          quote: "This app has completely transformed how I plan my outfits. The AI suggestions are surprisingly accurate and I've discovered combinations I never thought of!"
        },
        {
          name: "Michael Chen",
          role: "Marketing Manager",
          avatar_color: "from-blue-400 to-cyan-400",
          rating: 5,
          quote: "As someone who travels a lot for work, having my entire wardrobe digitized and getting outfit suggestions for different occasions is a game-changer."
        },
        {
          name: "Emma Rodriguez",
          role: "Style Consultant",
          avatar_color: "from-pink-400 to-red-400",
          rating: 5,
          quote: "I recommend OutfitMaker.ai to all my clients. It's like having a personal stylist in your pocket. The weather-based suggestions are incredibly practical."
        }
      ].each do |testimonial| %>
        <div class="bg-outfit-card border border-outfit-border rounded-2xl p-8 hover:border-white/20 transition-colors">
          <!-- Stars -->
          <div class="flex gap-1 mb-4">
            <% testimonial[:rating].times do %>
              <svg class="w-5 h-5 text-yellow-400" fill="currentColor" viewBox="0 0 20 20">
                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
              </svg>
            <% end %>
          </div>

          <!-- Quote -->
          <p class="text-text-secondary leading-relaxed mb-6">
            "<%= testimonial[:quote] %>"
          </p>

          <!-- Author -->
          <div class="flex items-center">
            <div class="w-12 h-12 rounded-full bg-gradient-to-br <%= testimonial[:avatar_color] %> flex items-center justify-center text-white font-semibold mr-4">
              <%= testimonial[:name].split.map(&:first).join %>
            </div>
            <div>
              <div class="font-semibold text-white"><%= testimonial[:name] %></div>
              <div class="text-sm text-text-muted"><%= testimonial[:role] %></div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
  </div>
</section>
```

---

### 8. Pricing Section (Optional for Beta)

```erb
<!-- app/views/landing/_pricing.html.erb -->
<section id="pricing" class="py-24 bg-outfit-bg">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <!-- Header -->
    <div class="text-center mb-16">
      <h2 class="text-4xl sm:text-5xl font-bold text-white mb-4">
        Simple, transparent pricing
      </h2>
      <p class="text-xl text-text-secondary">
        Start free, upgrade when you're ready
      </p>
    </div>

    <!-- Pricing Cards -->
    <div class="grid md:grid-cols-3 gap-8 max-w-5xl mx-auto">
      <!-- Free Tier -->
      <div class="bg-outfit-card border border-outfit-border rounded-2xl p-8">
        <h3 class="text-xl font-bold text-white mb-2">Free</h3>
        <div class="mb-6">
          <span class="text-4xl font-bold text-white">€0</span>
          <span class="text-text-muted">/month</span>
        </div>
        
        <ul class="space-y-3 mb-8">
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Up to 50 wardrobe items
          </li>
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Basic AI suggestions
          </li>
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Manual background removal
          </li>
        </ul>

        <%= link_to 'Get Started', new_user_registration_path, class: 'btn-secondary w-full text-center' %>
      </div>

      <!-- Premium Tier (Highlighted) -->
      <div class="relative bg-gradient-to-br from-purple-600/20 to-pink-600/20 border-2 border-purple-500 rounded-2xl p-8">
        <div class="absolute -top-4 left-1/2 -translate-x-1/2 bg-gradient-primary px-4 py-1 rounded-full text-sm font-medium text-white">
          Most Popular
        </div>

        <h3 class="text-xl font-bold text-white mb-2">Premium</h3>
        <div class="mb-6">
          <span class="text-4xl font-bold text-white">€7.99</span>
          <span class="text-text-muted">/month</span>
        </div>
        
        <ul class="space-y-3 mb-8">
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Unlimited wardrobe items
          </li>
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Advanced AI suggestions
          </li>
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Auto background removal
          </li>
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Visual search
          </li>
        </ul>

        <%= link_to 'Start Free Trial', new_user_registration_path, class: 'btn-primary w-full text-center' %>
      </div>

      <!-- Pro Tier -->
      <div class="bg-outfit-card border border-outfit-border rounded-2xl p-8">
        <h3 class="text-xl font-bold text-white mb-2">Pro</h3>
        <div class="mb-6">
          <span class="text-4xl font-bold text-white">€14.99</span>
          <span class="text-text-muted">/month</span>
        </div>
        
        <ul class="space-y-3 mb-8">
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Everything in Premium
          </li>
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Priority AI processing
          </li>
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Shopping recommendations
          </li>
          <li class="flex items-start text-text-secondary">
            <svg class="w-5 h-5 text-green-400 mr-2 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Early access to features
          </li>
        </ul>

        <%= link_to 'Get Started', new_user_registration_path, class: 'btn-secondary w-full text-center' %>
      </div>
    </div>
  </div>
</section>
```

---

### 9. Final CTA

```erb
<!-- app/views/landing/_final_cta.html.erb -->
<section class="py-24 bg-outfit-bg relative overflow-hidden">
  <!-- Background Effects -->
  <div class="absolute inset-0">
    <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-gradient-radial from-purple-500/20 via-pink-500/10 to-transparent blur-3xl"></div>
  </div>

  <div class="relative max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
    <!-- Badge -->
    <div class="inline-flex items-center px-4 py-2 bg-purple-500/10 border border-purple-500/20 rounded-full text-sm text-purple-300 mb-8">
      <span class="w-2 h-2 bg-purple-500 rounded-full animate-pulse mr-2"></span>
      Join 10,000+ users already organizing their wardrobes
    </div>

    <!-- Headline -->
    <h2 class="text-4xl sm:text-5xl lg:text-6xl font-bold text-white mb-6">
      Ready to transform your
      <span class="bg-gradient-primary bg-clip-text text-transparent">morning routine?</span>
    </h2>

    <!-- Subheadline -->
    <p class="text-xl text-text-secondary mb-10 max-w-2xl mx-auto">
      Start your free trial today. No credit card required. Cancel anytime.
    </p>

    <!-- CTA Buttons -->
    <div class="flex flex-col sm:flex-row gap-4 justify-center items-center mb-8">
      <%= link_to new_user_registration_path, class: 'btn-primary btn-lg group' do %>
        Get Started Free
        <svg class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
        </svg>
      <% end %>
      <span class="text-sm text-text-muted">
        or
      </span>
      <%= link_to new_user_session_path, class: 'text-purple-400 hover:text-purple-300 font-medium' do %>
        Sign in to your account →
      <% end %>
    </div>

    <!-- Trust Badges -->
    <div class="flex flex-wrap justify-center items-center gap-6 text-sm text-text-muted">
      <div class="flex items-center">
        <svg class="w-5 h-5 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
        </svg>
        No credit card required
      </div>
      <div class="flex items-center">
        <svg class="w-5 h-5 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
        </svg>
        14-day free trial
      </div>
      <div class="flex items-center">
        <svg class="w-5 h-5 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
        </svg>
        Cancel anytime
      </div>
    </div>
  </div>
</section>
```

---

### 10. Footer

```erb
<!-- app/views/layouts/_landing_footer.html.erb -->
<footer class="bg-outfit-card border-t border-outfit-border">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <div class="grid grid-cols-2 md:grid-cols-4 gap-8 mb-12">
      <!-- Product -->
      <div>
        <h4 class="text-white font-semibold mb-4">Product</h4>
        <ul class="space-y-2">
          <li><%= link_to 'Features', '#features', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Pricing', '#pricing', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'How It Works', '#how-it-works', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'FAQ', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
        </ul>
      </div>

      <!-- Company -->
      <div>
        <h4 class="text-white font-semibold mb-4">Company</h4>
        <ul class="space-y-2">
          <li><%= link_to 'About', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Blog', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Careers', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Contact', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
        </ul>
      </div>

      <!-- Resources -->
      <div>
        <h4 class="text-white font-semibold mb-4">Resources</h4>
        <ul class="space-y-2">
          <li><%= link_to 'Help Center', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'API Docs', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Community', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Status', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
        </ul>
      </div>

      <!-- Legal -->
      <div>
        <h4 class="text-white font-semibold mb-4">Legal</h4>
        <ul class="space-y-2">
          <li><%= link_to 'Privacy', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Terms', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Security', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
          <li><%= link_to 'Cookies', '#', class: 'text-text-secondary hover:text-white transition-colors' %></li>
        </ul>
      </div>
    </div>

    <!-- Bottom Bar -->
    <div class="pt-8 border-t border-outfit-border">
      <div class="flex flex-col md:flex-row justify-between items-center">
        <!-- Logo & Copyright -->
        <div class="flex items-center space-x-2 mb-4 md:mb-0">
          <div class="w-8 h-8 bg-gradient-primary rounded-lg flex items-center justify-center">
            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21a4 4 0 01-4-4V5a2 2 0 012-2h4a2 2 0 012 2v12a4 4 0 01-4 4zm0 0h12a2 2 0 002-2v-4a2 2 0 00-2-2h-2.343M11 7.343l1.657-1.657a2 2 0 012.828 0l2.829 2.829a2 2 0 010 2.828l-8.486 8.485M7 17h.01" />
            </svg>
          </div>
          <span class="text-text-muted text-sm">
            © 2026 OutfitMaker.ai. All rights reserved.
          </span>
        </div>

        <!-- Social Links -->
        <div class="flex items-center space-x-6">
          <a href="#" class="text-text-muted hover:text-white transition-colors">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M8.29 20.251c7.547 0 11.675-6.253 11.675-11.675 0-.178 0-.355-.012-.53A8.348 8.348 0 0022 5.92a8.19 8.19 0 01-2.357.646 4.118 4.118 0 001.804-2.27 8.224 8.224 0 01-2.605.996 4.107 4.107 0 00-6.993 3.743 11.65 11.65 0 01-8.457-4.287 4.106 4.106 0 001.27 5.477A4.072 4.072 0 012.8 9.713v.052a4.105 4.105 0 003.292 4.022 4.095 4.095 0 01-1.853.07 4.108 4.108 0 003.834 2.85A8.233 8.233 0 012 18.407a11.616 11.616 0 006.29 1.84" /></svg>
          </a>
          <a href="#" class="text-text-muted hover:text-white transition-colors">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12S18.627 0 12 0zm4.441 16.892c-2.102.144-6.784.144-8.883 0C5.282 16.736 5.017 15.622 5 12c.017-3.629.285-4.736 2.558-4.892 2.099-.144 6.782-.144 8.883 0C18.718 7.264 18.982 8.378 19 12c-.018 3.629-.285 4.736-2.559 4.892zM10 9.658l4.917 2.338L10 14.342V9.658z" /></svg>
          </a>
          <a href="#" class="text-text-muted hover:text-white transition-colors">
            <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.477 2 2 6.477 2 12c0 4.991 3.657 9.128 8.438 9.879V14.89h-2.54V12h2.54V9.797c0-2.506 1.492-3.89 3.777-3.89 1.094 0 2.238.195 2.238.195v2.46h-1.26c-1.243 0-1.63.771-1.63 1.562V12h2.773l-.443 2.89h-2.33v6.989C18.343 21.129 22 16.99 22 12c0-5.523-4.477-10-10-10z" /></svg>
          </a>
        </div>
      </div>
    </div>
  </div>
</footer>
```

---

## 💅 Utility CSS Classes (Add to application.tailwind.css)

```css
/* app/assets/stylesheets/application.tailwind.css */

@layer components {
  /* Button Styles */
  .btn-primary {
    @apply inline-flex items-center justify-center px-6 py-3 bg-gradient-primary text-white font-medium rounded-xl shadow-lg hover:shadow-xl hover:scale-105 transition-all duration-200;
  }

  .btn-secondary {
    @apply inline-flex items-center justify-center px-6 py-3 bg-outfit-card border-2 border-purple-500/50 text-white font-medium rounded-xl hover:bg-outfit-card-hover hover:border-purple-500 transition-all duration-200;
  }

  .btn-lg {
    @apply px-8 py-4 text-lg;
  }

  /* Glass Morphism */
  .glass {
    @apply bg-white/5 backdrop-blur-lg border border-white/10;
  }

  /* Gradient Text */
  .text-gradient-primary {
    @apply bg-gradient-primary bg-clip-text text-transparent;
  }

  .text-gradient-secondary {
    @apply bg-gradient-secondary bg-clip-text text-transparent;
  }

  /* Glow Effect */
  .glow-purple {
    @apply shadow-[0_0_30px_rgba(139,92,246,0.3)];
  }

  .glow-pink {
    @apply shadow-[0_0_30px_rgba(236,72,153,0.3)];
  }
}
```

---

## 📱 Stimulus Controllers

### Mobile Menu Controller

```javascript
// app/javascript/controllers/mobile_menu_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    this.menuTarget.classList.toggle("hidden")
  }

  close() {
    this.menuTarget.classList.add("hidden")
  }
}
```

### Scroll Animation Controller

```javascript
// app/javascript/controllers/scroll_animation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add("animate-fade-in")
        }
      })
    }, {
      threshold: 0.1
    })

    this.element.querySelectorAll('[data-scroll-animate]').forEach(el => {
      this.observer.observe(el)
    })
  }

  disconnect() {
    this.observer.disconnect()
  }
}
```

---

## 🎬 Final Landing Page Layout

```erb
<!-- app/views/pages/landing.html.erb -->
<!DOCTYPE html>
<html lang="en" class="scroll-smooth">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OutfitMaker.ai - Your AI-Powered Wardrobe Assistant</title>
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
  <%= javascript_importmap_tags %>
</head>

<body class="bg-outfit-bg text-white antialiased" data-controller="scroll-animation">
  <!-- Navigation -->
  <%= render 'layouts/landing_nav' %>

  <!-- Hero Section -->
  <%= render 'landing/hero' %>

  <!-- Social Proof -->
  <%= render 'landing/social_proof' %>

  <!-- Features -->
  <%= render 'landing/features' %>

  <!-- Product Demo -->
  <%= render 'landing/demo' %>

  <!-- How It Works -->
  <%= render 'landing/how_it_works' %>

  <!-- Testimonials -->
  <%= render 'landing/testimonials' %>

  <!-- Pricing (Optional) -->
  <%= render 'landing/pricing' if show_pricing? %>

  <!-- Final CTA -->
  <%= render 'landing/final_cta' %>

  <!-- Footer -->
  <%= render 'layouts/landing_footer' %>
</body>
</html>
```

---

## 🚀 Implementation Roadmap

### Week 1: Foundation
- [ ] Set up Tailwind config with custom colors
- [ ] Create navigation and footer partials
- [ ] Build hero section

### Week 2: Core Sections
- [ ] Features grid
- [ ] Social proof section
- [ ] How It Works timeline

### Week 3: Advanced Sections
- [ ] Product demo with video
- [ ] Testimonials
- [ ] Pricing cards (if needed)

### Week 4: Polish & Deploy
- [ ] Add animations
- [ ] Mobile optimization
- [ ] Performance testing
- [ ] Deploy to production

---

## 📦 Assets Needed

### Images/Screenshots
1. Hero mockup (phone with app)
2. Product demo screenshots/video
3. Feature icons (using Heroicons)
4. User avatar placeholders

### Optional
- Logo variations
- Brand illustrations
- Partner/press logos

---

## ✅ Pre-Launch Checklist

- [ ] All sections responsive (test 320px to 4K)
- [ ] Fast loading (<3s on 3G)
- [ ] Accessibility (WCAG AA)
- [ ] SEO optimized (meta tags, Open Graph)
- [ ] Analytics integrated (Plausible)
- [ ] Forms working (signup, waitlist)
- [ ] CTAs tracked (conversions)

---

**🎉 You now have a complete, production-ready landing page component library!**

This design system gives you:
- ✅ Modern AI SaaS aesthetic
- ✅ Codia AI dark theme
- ✅ Reusable component library
- ✅ Mobile-first responsive design
- ✅ Smooth animations
- ✅ Glass morphism effects
- ✅ Ready for Claude Code to implement

**Next:** Share this with Claude Code to start building! 🚀
