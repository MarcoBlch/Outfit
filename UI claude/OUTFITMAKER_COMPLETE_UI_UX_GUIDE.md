# OutfitMaker.ai - Complete UI/UX Implementation Guide

## 📋 Document Overview

**Purpose**: This is the single source of truth for implementing OutfitMaker.ai's user interface and experience. It combines branding, design system, user flows, and component specifications into one actionable guide.

**Target Audience**: Claude Code, developers, designers

**Last Updated**: January 21, 2026

---

## 🎨 Brand Identity & Visual Language

### Logo System

**Primary Logo**: Option 4 - AI Sparkles (Recommended)
- **File**: `logo_option_4.svg`
- **Style**: Clean "O" with multiple AI sparkles
- **Gradient**: Deep blue (#4F46E5) → purple (#7C3AED) → blue (#2563EB)
- **Sparkle Colors**: #4FACFE, #00F2FE, #A78BFA
- **Brand Story**: The 'O' represents your wardrobe (complete, circular). The AI sparkles show intelligence working to create perfect combinations from what you already own.

**Logo Variations Needed**:
1. **Primary** (512x512px) - Full gradient background
2. **Icon Only** - Just the "O" + sparkles (no background) for favicons
3. **White Version** - For dark backgrounds
4. **Monochrome** - For print materials
5. **Horizontal Lockup** - Logo + "OutfitMaker.ai" text side-by-side

**Usage Examples**:
```html
<!-- Navigation (40x40px) -->
<img src="logo_option_4.svg" class="w-10 h-10" />

<!-- Hero Section (80x80px) -->
<img src="logo_option_4.svg" class="w-20 h-20" />

<!-- Favicon -->
<link rel="icon" type="image/svg+xml" href="logo_option_4.svg">
```

---

## 🌈 Design System

### Color Palette

**Primary Gradients**:
```css
/* Main Brand Gradient */
--gradient-primary: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

/* Secondary Accent */
--gradient-secondary: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);

/* AI/Tech Accent */
--gradient-accent: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);

/* Warm Accent */
--gradient-warm: linear-gradient(135deg, #fa709a 0%, #fee140 100%);

/* Radial Glow */
--gradient-radial: radial-gradient(circle at center, var(--tw-gradient-stops));
```

**Dark Theme (Primary)**:
```css
/* Purple Scale */
--purple-500: #8B5CF6;
--purple-600: #7C3AED;
--purple-700: #6D28D9;

/* Indigo Scale */
--indigo-500: #6366F1;
--indigo-600: #4F46E5;

/* Pink Scale */
--pink-500: #EC4899;
--pink-600: #DB2777;

/* Dark Theme Colors */
--bg-dark: #0F0F0F;
--bg-card: #1A1A1B;
--bg-card-hover: #242526;
--border-dark: #2A2A2C;

/* Text Colors (Dark Mode) */
--text-primary: #FFFFFF;
--text-secondary: #A0A0A3;
--text-muted: #6B6B6E;
```

**Light Theme**:
```css
/* Light Theme Colors */
--bg-light: #FFFFFF;
--bg-card-light: #F9FAFB;
--bg-card-hover-light: #F3F4F6;
--border-light: #E5E7EB;

/* Text Colors (Light Mode) */
--text-primary-light: #111827;
--text-secondary-light: #6B7280;
--text-muted-light: #9CA3AF;
```

---

## 🌓 Dark/Light Mode System

### Theme Toggle Implementation

**Default**: Dark mode (user preference saved in localStorage)

**Toggle Component**:
```tsx
// components/ThemeToggle.tsx
'use client';

import { useEffect, useState } from 'react';
import { Moon, Sun } from 'lucide-react';

export function ThemeToggle() {
  const [theme, setTheme] = useState<'dark' | 'light'>('dark');

  useEffect(() => {
    // Check localStorage and system preference on mount
    const savedTheme = localStorage.getItem('theme') as 'dark' | 'light' | null;
    const systemPreference = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    const initialTheme = savedTheme || systemPreference;
    
    setTheme(initialTheme);
    document.documentElement.classList.toggle('dark', initialTheme === 'dark');
  }, []);

  const toggleTheme = () => {
    const newTheme = theme === 'dark' ? 'light' : 'dark';
    setTheme(newTheme);
    localStorage.setItem('theme', newTheme);
    document.documentElement.classList.toggle('dark', newTheme === 'dark');
  };

  return (
    <button
      onClick={toggleTheme}
      className="p-2 rounded-lg bg-outfit-card hover:bg-outfit-card-hover border border-outfit-border transition-colors"
      aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}
    >
      {theme === 'dark' ? (
        <Sun className="w-5 h-5 text-yellow-400" />
      ) : (
        <Moon className="w-5 h-5 text-indigo-600" />
      )}
    </button>
  );
}
```

### Tailwind Dark Mode Configuration

```javascript
// tailwind.config.js
module.exports = {
  darkMode: 'class', // Use class-based dark mode
  theme: {
    extend: {
      colors: {
        outfit: {
          // Dark mode colors
          bg: '#0F0F0F',
          card: '#1A1A1B',
          'card-hover': '#242526',
          border: '#2A2A2C',
        }
      },
      // Add light mode variants
      backgroundColor: {
        'light-bg': '#FFFFFF',
        'light-card': '#F9FAFB',
        'light-card-hover': '#F3F4F6',
      },
      borderColor: {
        'light-border': '#E5E7EB',
      },
      textColor: {
        'light-primary': '#111827',
        'light-secondary': '#6B7280',
        'light-muted': '#9CA3AF',
      }
    },
  },
}
```

### CSS Variables Approach (Recommended)

```css
/* globals.css */
:root {
  /* Light mode (default for :root) */
  --bg-primary: 255 255 255; /* #FFFFFF */
  --bg-card: 249 250 251; /* #F9FAFB */
  --bg-card-hover: 243 244 246; /* #F3F4F6*/
  --border: 229 231 235; /* #E5E7EB */
  
  --text-primary: 17 24 39; /* #111827 */
  --text-secondary: 107 114 128; /* #6B7280 */
  --text-muted: 156 163 175; /* #9CA3AF */
}

.dark {
  /* Dark mode overrides */
  --bg-primary: 15 15 15; /* #0F0F0F */
  --bg-card: 26 26 27; /* #1A1A1B */
  --bg-card-hover: 36 37 38; /* #242526 */
  --border: 42 42 44; /* #2A2A2C */
  
  --text-primary: 255 255 255; /* #FFFFFF */
  --text-secondary: 160 160 163; /* #A0A0A3 */
  --text-muted: 107 107 110; /* #6B6B6E */
}

/* Usage with Tailwind */
.bg-primary {
  background-color: rgb(var(--bg-primary));
}

.text-primary {
  color: rgb(var(--text-primary));
}
```

### Component Usage Examples

**Navbar with Theme Toggle**:
```tsx
<nav className="bg-outfit-bg dark:bg-outfit-bg border-b border-outfit-border dark:border-outfit-border">
  <div className="flex items-center justify-between">
    {/* Logo */}
    <div>...</div>
    
    {/* Theme Toggle in Navigation */}
    <div className="flex items-center gap-4">
      <ThemeToggle />
      <button className="btn-primary">Sign In</button>
    </div>
  </div>
</nav>
```

**Card Component (Auto-switches)**:
```tsx
<div className="bg-outfit-card dark:bg-outfit-card hover:bg-outfit-card-hover dark:hover:bg-outfit-card-hover border border-outfit-border dark:border-outfit-border rounded-xl p-6 transition-colors">
  <h3 className="text-text-primary dark:text-text-primary">Card Title</h3>
  <p className="text-text-secondary dark:text-text-secondary">Card description</p>
</div>
```

**Better Approach Using CSS Variables**:
```tsx
// No need for dark: classes everywhere
<div className="bg-[rgb(var(--bg-card))] border-[rgb(var(--border))] rounded-xl p-6">
  <h3 className="text-[rgb(var(--text-primary))]">Card Title</h3>
  <p className="text-[rgb(var(--text-secondary))]">Card description</p>
</div>
```

### Gradient Adjustments for Light Mode

**Challenge**: Purple/pink gradients on white backgrounds may lack contrast

**Solution**: Adjust gradient opacity or use darker variants in light mode

```css
/* Dark mode: Full opacity gradients */
.dark .btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

/* Light mode: Slightly darker/more saturated */
.btn-primary {
  background: linear-gradient(135deg, #5b6fd8 0%, #6b4190 100%);
}

/* OR: Add subtle shadow for depth in light mode */
.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.dark .btn-primary {
  box-shadow: 0 4px 16px rgba(102, 126, 234, 0.4);
}
```

### Image Handling in Different Themes

**Logo Variants**:
```tsx
// Show different logo for light/dark mode
<img 
  src="/logo-dark.svg" 
  className="block dark:hidden" 
  alt="OutfitMaker.ai"
/>
<img 
  src="/logo-light.svg" 
  className="hidden dark:block" 
  alt="OutfitMaker.ai"
/>
```

**Wardrobe Item Cards**:
```tsx
// Items always on white/light background for consistency
<div className="bg-white dark:bg-gray-100 rounded-xl p-4">
  <img src="item.png" alt="Navy Blazer" className="w-full" />
</div>
```

### Animation Background Orbs (Theme-Aware)

```html
<!-- Dark mode: Purple/Pink orbs -->
<div className="hidden dark:block absolute inset-0">
  <div className="absolute top-0 -left-4 w-96 h-96 bg-purple-500/20 rounded-full blur-3xl animate-float"></div>
  <div className="absolute top-0 -right-4 w-96 h-96 bg-pink-500/20 rounded-full blur-3xl animate-float"></div>
</div>

<!-- Light mode: Softer pastel orbs -->
<div className="block dark:hidden absolute inset-0">
  <div className="absolute top-0 -left-4 w-96 h-96 bg-purple-200/30 rounded-full blur-3xl animate-float"></div>
  <div className="absolute top-0 -right-4 w-96 h-96 bg-pink-200/30 rounded-full blur-3xl animate-float"></div>
</div>
```

### User Preference Persistence

**Save to Database** (for logged-in users):
```typescript
// app/api/user/preferences/route.ts
export async function POST(req: Request) {
  const { theme } = await req.json();
  const userId = await getCurrentUserId();
  
  await db.user.update({
    where: { id: userId },
    data: { 
      preferences: {
        theme: theme // 'dark' | 'light'
      }
    }
  });
  
  return Response.json({ success: true });
}
```

**Load on Login**:
```typescript
useEffect(() => {
  if (user?.preferences?.theme) {
    setTheme(user.preferences.theme);
    document.documentElement.classList.toggle('dark', user.preferences.theme === 'dark');
  }
}, [user]);
```

### Accessibility Considerations

**Respect System Preferences**:
```typescript
// Detect system preference
const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;

// Listen for system changes
window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
  if (!localStorage.getItem('theme')) {
    // Only auto-switch if user hasn't manually set preference
    const newTheme = e.matches ? 'dark' : 'light';
    setTheme(newTheme);
    document.documentElement.classList.toggle('dark', newTheme === 'dark');
  }
});
```

**WCAG Compliance in Both Modes**:
- Ensure 4.5:1 contrast ratio for text in BOTH themes
- Test with Chrome DevTools → Rendering → Emulate vision deficiencies
- Use tools like [Contrast Checker](https://webaim.org/resources/contrastchecker/)

### Testing Checklist

**Dark Mode**:
- [ ] All text readable (contrast check)
- [ ] Cards/borders visible
- [ ] Gradients pop on dark backgrounds
- [ ] Images/logos display correctly
- [ ] Hover states work

**Light Mode**:
- [ ] All text readable (contrast check)
- [ ] Cards/borders visible (not washed out)
- [ ] Gradients have enough contrast
- [ ] Background orbs not too harsh
- [ ] Shadows provide depth

**Toggle**:
- [ ] Smooth transition (no flash)
- [ ] Preference persists (localStorage)
- [ ] Syncs across tabs (storage event)
- [ ] Works on mobile
- [ ] Accessible keyboard navigation

---

## 🎨 Solid Colors
```css
/* Purple Scale */
--purple-500: #8B5CF6;
--purple-600: #7C3AED;
--purple-700: #6D28D9;

/* Indigo Scale */
--indigo-500: #6366F1;
--indigo-600: #4F46E5;

/* Pink Scale */
--pink-500: #EC4899;
--pink-600: #DB2777;

/* Dark Theme (Primary) */
--bg-dark: #0F0F0F;
--bg-card: #1A1A1B;
--bg-card-hover: #242526;
--border-dark: #2A2A2C;

/* Text Colors */
--text-primary: #FFFFFF;
--text-secondary: #A0A0A3;
--text-muted: #6B6B6E;
```

**Tailwind Configuration**:
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

### Typography

**Font Stack**:
- **Primary**: System fonts for speed (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`)
- **Headers**: Custom brand font (optional, load async)
- **Minimum Body**: 16px
- **Line Height**: 1.5 for body text, 1.2 for headers

**Type Scale**:
```css
--text-xs: 0.75rem;    /* 12px */
--text-sm: 0.875rem;   /* 14px */
--text-base: 1rem;     /* 16px */
--text-lg: 1.125rem;   /* 18px */
--text-xl: 1.25rem;    /* 20px */
--text-2xl: 1.5rem;    /* 24px */
--text-3xl: 1.875rem;  /* 30px */
--text-4xl: 2.25rem;   /* 36px */
--text-5xl: 3rem;      /* 48px */
--text-6xl: 3.75rem;   /* 60px */
--text-7xl: 4.5rem;    /* 72px */
```

### Spacing System

**Base Grid**: 8px
```css
--spacing-1: 0.25rem;  /* 4px */
--spacing-2: 0.5rem;   /* 8px */
--spacing-3: 0.75rem;  /* 12px */
--spacing-4: 1rem;     /* 16px */
--spacing-6: 1.5rem;   /* 24px */
--spacing-8: 2rem;     /* 32px */
--spacing-12: 3rem;    /* 48px */
--spacing-16: 4rem;    /* 64px */
--spacing-24: 6rem;    /* 96px */
```

### Component Styles

**Buttons**:
```css
/* Primary Button */
.btn-primary {
  @apply inline-flex items-center justify-center px-6 py-3;
  @apply bg-gradient-primary text-white font-medium rounded-xl;
  @apply shadow-lg hover:shadow-xl hover:scale-105;
  @apply transition-all duration-200;
}

/* Secondary Button */
.btn-secondary {
  @apply inline-flex items-center justify-center px-6 py-3;
  @apply bg-outfit-card border-2 border-purple-500/50 text-white font-medium rounded-xl;
  @apply hover:bg-outfit-card-hover hover:border-purple-500;
  @apply transition-all duration-200;
}

/* Large Button */
.btn-lg {
  @apply px-8 py-4 text-lg;
}
```

**Cards**:
```css
/* Glass Morphism Card */
.glass {
  @apply bg-white/5 backdrop-blur-lg border border-white/10;
}

/* Standard Card */
.card {
  @apply bg-outfit-card hover:bg-outfit-card-hover;
  @apply border border-outfit-border hover:border-white/20;
  @apply rounded-2xl p-8 transition-all duration-300;
}
```

**Effects**:
```css
/* Gradient Text */
.text-gradient-primary {
  @apply bg-gradient-primary bg-clip-text text-transparent;
}

/* Glow Effect */
.glow-purple {
  @apply shadow-[0_0_30px_rgba(139,92,246,0.3)];
}
```

---

## 🎬 Video Animations Integration

**Context**: You've provided 3 video files showing desired animations and interactions:
1. `Here_is_a_1080p_202601201747.mp4`
2. `The_context_you_1080p_202601201732.mp4`
3. `I_would_like_1080p_202601201728.mp4`

### Video Implementation Strategy

**Option 1: Hero Background Video**
```html
<div class="relative min-h-screen overflow-hidden">
  <!-- Background Video -->
  <video
    autoplay
    loop
    muted
    playsinline
    class="absolute inset-0 w-full h-full object-cover opacity-20"
  >
    <source src="/videos/hero-animation.mp4" type="video/mp4">
  </video>
  
  <!-- Overlay Gradient -->
  <div class="absolute inset-0 bg-gradient-to-b from-outfit-bg/80 to-outfit-bg"></div>
  
  <!-- Content on top -->
  <div class="relative z-10">
    <!-- Hero content here -->
  </div>
</div>
```

**Option 2: Demo Section Video**
```html
<div class="relative bg-outfit-card rounded-2xl border border-outfit-border overflow-hidden shadow-2xl">
  <video
    controls
    poster="/images/video-thumbnail.jpg"
    class="w-full aspect-video"
  >
    <source src="/videos/product-demo.mp4" type="video/mp4">
  </video>
  
  <!-- Play Button Overlay (custom) -->
  <button class="absolute inset-0 flex items-center justify-center bg-black/30 hover:bg-black/50 transition-colors">
    <div class="w-20 h-20 bg-white rounded-full flex items-center justify-center shadow-lg">
      <svg class="w-10 h-10 text-purple-600 ml-1" fill="currentColor">
        <path d="M8 5v14l11-7z" />
      </svg>
    </div>
  </button>
</div>
```

**Option 3: Feature Showcase Carousel**
```html
<div class="swiper-container">
  <div class="swiper-wrapper">
    <div class="swiper-slide">
      <video autoplay loop muted playsinline>
        <source src="/videos/feature-1.mp4" type="video/mp4">
      </video>
    </div>
    <div class="swiper-slide">
      <video autoplay loop muted playsinline>
        <source src="/videos/feature-2.mp4" type="video/mp4">
      </video>
    </div>
  </div>
</div>
```

**Video Optimization**:
- Compress to <5MB for web delivery
- Generate WebM version for better compression
- Create poster images (first frame screenshot)
- Lazy load videos below fold
- Pause on scroll out of view (performance)

---

## 📱 Landing Page Structure & Components

### Page Architecture

```
┌─────────────────────────────────────┐
│ 1. Navigation (Fixed Top)           │
├─────────────────────────────────────┤
│ 2. Hero Section                     │
│    - Headline with gradient         │
│    - Subheadline                    │
│    - CTA buttons                    │
│    - Hero visual (video/3D mockup)  │
├─────────────────────────────────────┤
│ 3. Social Proof                     │
│    - User stats                     │
│    - Trust badges                   │
├─────────────────────────────────────┤
│ 4. Features Grid (3 columns)        │
│    - Smart Photo Capture            │
│    - AI Outfit Suggestions          │
│    - Visual Search                  │
│    - Style Quiz                     │
│    - Weather-Aware                  │
│    - Shopping Integration           │
├─────────────────────────────────────┤
│ 5. Product Demo (Video)             │
│    - Large video/screenshot         │
│    - Feature callouts               │
├─────────────────────────────────────┤
│ 6. How It Works (3 Steps)           │
│    - Visual timeline                │
├─────────────────────────────────────┤
│ 7. Testimonials                     │
│    - User quotes + avatars          │
├─────────────────────────────────────┤
│ 8. Pricing (Optional for Beta)      │
│    - 3 tiers                        │
├─────────────────────────────────────┤
│ 9. Final CTA                        │
│    - Large signup section           │
├─────────────────────────────────────┤
│ 10. Footer                          │
│    - Links, social, legal           │
└─────────────────────────────────────┘
```

### 1. Navigation Component

**Desktop Navigation**:
```html
<nav class="fixed top-0 left-0 right-0 z-50 bg-outfit-bg/80 backdrop-blur-lg border-b border-outfit-border">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex items-center justify-between h-16">
      
      <!-- Logo -->
      <a href="/" class="flex items-center space-x-2 group">
        <img src="logo_option_4.svg" class="w-10 h-10 group-hover:scale-105 transition-transform" alt="OutfitMaker.ai" />
        <span class="text-xl font-bold bg-gradient-primary bg-clip-text text-transparent">
          OutfitMaker.ai
        </span>
      </a>

      <!-- Desktop Links -->
      <div class="hidden md:flex items-center space-x-8">
        <a href="#features" class="text-text-secondary hover:text-text-primary transition-colors">Features</a>
        <a href="#how-it-works" class="text-text-secondary hover:text-text-primary transition-colors">How It Works</a>
        <a href="#pricing" class="text-text-secondary hover:text-text-primary transition-colors">Pricing</a>
        <a href="/blog" class="text-text-secondary hover:text-text-primary transition-colors">Blog</a>
      </div>

      <!-- CTA Buttons -->
      <div class="flex items-center space-x-4">
        <!-- Theme Toggle -->
        <button 
          id="theme-toggle"
          class="p-2 rounded-lg bg-outfit-card hover:bg-outfit-card-hover border border-outfit-border transition-colors"
          aria-label="Toggle theme"
        >
          <svg class="w-5 h-5 text-yellow-400 hidden dark:block" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" />
          </svg>
          <svg class="w-5 h-5 text-indigo-600 block dark:hidden" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" />
          </svg>
        </button>
        
        <a href="/signin" class="hidden sm:block text-text-secondary hover:text-text-primary transition-colors">
          Sign In
        </a>
        <a href="/signup" class="btn-primary">
          Start Free Trial
          <svg class="w-4 h-4 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
          </svg>
        </a>
      </div>

      <!-- Mobile Menu Button -->
      <button class="md:hidden p-2 text-text-secondary">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
        </svg>
      </button>
    </div>
  </div>
</nav>
```

### 2. Hero Section

**Key Elements**:
- Bold headline with gradient text
- Engaging subheadline
- Dual CTA buttons (primary + secondary)
- Hero visual (video mockup or 3D element)
- Floating animated elements
- Social proof badges

**Implementation**:
```html
<section class="relative min-h-screen flex items-center justify-center overflow-hidden bg-outfit-bg">
  
  <!-- Animated Background -->
  <div class="absolute inset-0">
    <!-- Gradient Orbs -->
    <div class="absolute top-0 -left-4 w-96 h-96 bg-purple-500/20 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-float"></div>
    <div class="absolute top-0 -right-4 w-96 h-96 bg-pink-500/20 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-float" style="animation-delay: 2s;"></div>
    <div class="absolute -bottom-8 left-20 w-96 h-96 bg-indigo-500/20 rounded-full mix-blend-multiply filter blur-3xl opacity-70 animate-float" style="animation-delay: 4s;"></div>
    
    <!-- Grid Pattern -->
    <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,...')] opacity-20"></div>
  </div>

  <!-- Content -->
  <div class="relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20">
    <div class="grid lg:grid-cols-2 gap-12 items-center">
      
      <!-- Left: Text Content -->
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
          <a href="/signup" class="btn-primary btn-lg group">
            Start Free Trial
            <svg class="w-5 h-5 ml-2 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
            </svg>
          </a>
          <a href="#demo" class="btn-secondary btn-lg group">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Watch Demo
          </a>
        </div>

        <!-- Social Proof -->
        <div class="flex items-center gap-8 justify-center lg:justify-start text-sm text-text-muted">
          <div class="flex items-center">
            <div class="flex -space-x-2">
              <div class="w-8 h-8 rounded-full bg-gradient-to-br from-purple-400 to-pink-400 border-2 border-outfit-bg"></div>
              <div class="w-8 h-8 rounded-full bg-gradient-to-br from-blue-400 to-cyan-400 border-2 border-outfit-bg"></div>
              <div class="w-8 h-8 rounded-full bg-gradient-to-br from-pink-400 to-red-400 border-2 border-outfit-bg"></div>
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

      <!-- Right: Hero Visual -->
      <div class="relative lg:h-[600px]">
        <div class="relative mx-auto w-full max-w-sm">
          
          <!-- Glass Card with App Preview -->
          <div class="relative bg-outfit-card/40 backdrop-blur-xl rounded-3xl border border-white/10 p-8 shadow-2xl animate-float">
            
            <!-- Mockup Content -->
            <div class="aspect-[9/16] bg-gradient-to-br from-purple-500/20 to-pink-500/20 rounded-2xl border border-white/10 overflow-hidden">
              <!-- Video or Screenshot -->
              <video autoplay loop muted playsinline class="w-full h-full object-cover">
                <source src="/videos/app-demo.mp4" type="video/mp4">
              </video>
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

### 3. Social Proof Section

```html
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

  </div>
</section>
```

### 4. Features Grid

**6 Core Features to Highlight**:
1. Smart Photo Capture - Auto background removal & categorization
2. AI Outfit Suggestions - Personalized recommendations
3. Visual Search - Find similar items
4. Style Quiz - Understand preferences
5. Weather-Aware - Context-based suggestions
6. Shopping Integration - Complete your look

```html
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
      <div class="group relative bg-outfit-card hover:bg-outfit-card-hover border border-outfit-border hover:border-white/20 rounded-2xl p-8 transition-all duration-300 hover:-translate-y-1">
        
        <!-- Gradient Border on Hover -->
        <div class="absolute inset-0 bg-gradient-to-r from-purple-500 to-pink-500 opacity-0 group-hover:opacity-10 rounded-2xl transition-opacity"></div>
        
        <!-- Icon -->
        <div class="relative w-14 h-14 bg-gradient-to-br from-purple-500 to-pink-500 rounded-xl flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
          <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
        </div>

        <!-- Content -->
        <h3 class="text-xl font-semibold text-white mb-3">Smart Photo Capture</h3>
        <p class="text-text-secondary leading-relaxed">
          Snap a photo of any clothing item. Our AI automatically removes backgrounds and tags items by category, color, and style.
        </p>

        <!-- Arrow Icon -->
        <div class="mt-4 text-purple-400 opacity-0 group-hover:opacity-100 transition-opacity">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
          </svg>
        </div>
      </div>

      <!-- Repeat for other 5 features with different icons/gradients -->
      
    </div>
  </div>
</section>
```

### 5. Product Demo Section

```html
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

        <a href="/signup" class="btn-primary inline-flex items-center">
          Try It Free
          <svg class="w-5 h-5 ml-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6" />
          </svg>
        </a>
      </div>

      <!-- Right: Video Demo -->
      <div class="relative">
        <div class="relative bg-outfit-card rounded-2xl border border-outfit-border overflow-hidden shadow-2xl">
          
          <!-- Video Player -->
          <video
            controls
            poster="/images/demo-thumbnail.jpg"
            class="w-full aspect-video"
          >
            <source src="/videos/product-demo.mp4" type="video/mp4">
          </video>

          <!-- Feature Callout -->
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

## 🎯 User Onboarding Flow (Post-Signup)

### Style Quiz Implementation

**Context**: After users click the primary CTA ("Start Free Trial"), they should complete a style questionnaire to personalize their experience.

### Quiz Structure

**Total Questions**: 8-10 questions
**Estimated Time**: 2-3 minutes
**Format**: Single-page with progress indicator

### Question Set

**Q1: Personal Style Preference**
```
Question: "How would you describe your personal style?"
Type: Multiple choice (single select)
Options:
- Classic & Timeless
- Trendy & Fashion-Forward
- Casual & Comfortable
- Edgy & Bold
- Minimalist & Clean
- Eclectic & Creative
- Sporty & Active
- Elegant & Sophisticated

Visual: Show outfit examples for each style
```

**Q2: Color Preferences**
```
Question: "What colors do you gravitate towards?"
Type: Multiple choice (multi-select, max 5)
Options: Color swatches
- Neutrals (Black, White, Gray, Beige, Navy)
- Earth Tones (Brown, Olive, Tan, Rust)
- Pastels (Pink, Lavender, Mint, Peach)
- Jewel Tones (Emerald, Sapphire, Ruby, Amethyst)
- Bright Colors (Red, Yellow, Blue, Green)
- Monochrome (Black & White only)

Visual: Interactive color palette
```

**Q3: Occasion Focus**
```
Question: "What occasions do you dress for most often?"
Type: Multiple choice (multi-select, max 3)
Options:
- Work/Professional
- Casual Daily Wear
- Social Events & Parties
- Date Nights
- Fitness & Sports
- Formal Events
- Travel & Vacation
- Creative/Artistic Work

Visual: Icon representations
```

**Q4: Body Type & Fit Preference**
```
Question: "What fit makes you feel most confident?"
Type: Multiple choice (single select)
Options:
- Loose & Relaxed
- Fitted & Tailored
- Balanced (Mix of both)
- Oversized & Streetwear
- Prefer not to say

Visual: Silhouette illustrations
```

**Q5: Current Wardrobe Size**
```
Question: "How would you describe your current wardrobe?"
Type: Multiple choice (single select)
Options:
- Minimal (< 30 items)
- Small (30-50 items)
- Medium (50-100 items)
- Large (100-200 items)
- Extensive (200+ items)

Purpose: Set expectations for outfit combinations
```

**Q6: Shopping Behavior**
```
Question: "How often do you shop for new clothes?"
Type: Multiple choice (single select)
Options:
- Weekly
- Monthly
- Seasonally (4x/year)
- Rarely (1-2x/year)
- Only when needed

Purpose: Tailor shopping recommendations
```

**Q7: Budget Range**
```
Question: "What's your typical budget for a single clothing item?"
Type: Multiple choice (single select)
Options:
- Under $30
- $30-$75
- $75-$150
- $150-$300
- $300+
- Varies widely

Purpose: Personalize shopping suggestions (Phase 4)
```

**Q8: Presentation Style** (Critical for AI)
```
Question: "How do you prefer to present yourself?"
Type: Multiple choice (single select)
Options:
- Feminine
- Masculine
- Androgynous/Neutral
- Fluid (Varies by mood)
- Prefer not to say

Purpose: Critical for AI outfit suggestions (avoid style mismatches)
```

**Q9: Fashion Inspiration Sources**
```
Question: "Where do you find fashion inspiration?"
Type: Multiple choice (multi-select)
Options:
- Instagram/TikTok
- Pinterest
- Fashion Magazines
- Celebrity Style
- Runway Shows
- Street Style
- Friends & Family
- I don't follow fashion trends

Purpose: Understand influences for recommendations
```

**Q10: Primary Goal**
```
Question: "What's your main goal with OutfitMaker?"
Type: Multiple choice (single select)
Options:
- Organize my existing wardrobe
- Get daily outfit suggestions
- Discover new style combinations
- Plan outfits for specific events
- Reduce decision fatigue
- Shop smarter
- All of the above

Purpose: Prioritize feature onboarding
```

### Quiz UI Implementation

```html
<div class="min-h-screen bg-outfit-bg flex items-center justify-center p-4">
  <div class="max-w-2xl w-full">
    
    <!-- Progress Bar -->
    <div class="mb-8">
      <div class="flex items-center justify-between text-sm text-text-muted mb-2">
        <span>Question 1 of 10</span>
        <span>10% Complete</span>
      </div>
      <div class="h-2 bg-outfit-card rounded-full overflow-hidden">
        <div class="h-full bg-gradient-primary transition-all duration-300" style="width: 10%"></div>
      </div>
    </div>

    <!-- Question Card -->
    <div class="bg-outfit-card border border-outfit-border rounded-2xl p-8 mb-6">
      
      <!-- Question -->
      <h2 class="text-2xl font-bold text-white mb-6">
        How would you describe your personal style?
      </h2>

      <!-- Options Grid -->
      <div class="grid grid-cols-2 gap-4">
        
        <!-- Option Card -->
        <button class="group relative bg-outfit-bg hover:bg-outfit-card-hover border-2 border-outfit-border hover:border-purple-500 rounded-xl p-6 transition-all text-left">
          
          <!-- Image Preview -->
          <div class="aspect-square rounded-lg overflow-hidden mb-4">
            <img src="/images/styles/classic.jpg" alt="Classic Style" class="w-full h-full object-cover group-hover:scale-105 transition-transform" />
          </div>

          <!-- Label -->
          <div class="font-medium text-white mb-1">Classic & Timeless</div>
          <div class="text-sm text-text-muted">Elegant, traditional pieces</div>

          <!-- Checkmark (when selected) -->
          <div class="absolute top-4 right-4 w-6 h-6 bg-purple-500 rounded-full flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
            <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
          </div>
        </button>

        <!-- Repeat for 8 options -->
        
      </div>
    </div>

    <!-- Navigation -->
    <div class="flex items-center justify-between">
      <button class="text-text-secondary hover:text-white transition-colors">
        ← Back
      </button>
      <button class="btn-primary">
        Next Question →
      </button>
    </div>

  </div>
</div>
```

### Quiz Completion Flow

**After Q10**:
1. Show "Analyzing your style..." loading screen (2-3 seconds)
2. Display personalized summary:
   - "Your Style Profile: Classic Minimalist"
   - "Top Colors: Navy, White, Beige"
   - "Perfect for: Work & Casual Events"
3. CTA: "Start Building Your Wardrobe" → Takes to dashboard

---

## 📐 App Dashboard Layout

### Dashboard Structure

```
┌────────────────────────────────────────────────┐
│ Top Navigation                                 │
│ [Logo] [Dashboard] [Wardrobe] [Outfits] [👤]  │
├────────────────────────────────────────────────┤
│                                                │
│ Hero Banner (Personalized)                    │
│ "Good morning, Sarah!"                         │
│ Weather: 72°F, Sunny ☀️                        │
│                                                │
├────────────────────────────────────────────────┤
│                                                │
│ Quick Actions                                  │
│ [📸 Add Item] [✨ Get Outfit] [📅 Calendar]   │
│                                                │
├────────────────────────────────────────────────┤
│                                                │
│ Today's Outfit Suggestion                      │
│ [AI-generated outfit display]                  │
│                                                │
├────────────────────────────────────────────────┤
│                                                │
│ Recent Activity Feed                           │
│ - Items added                                  │
│ - Outfits created                              │
│ - Suggestions saved                            │
│                                                │
└────────────────────────────────────────────────┘
```

### Wardrobe Grid View

**Layout**: Masonry grid or standard grid
**Item Card**:
```html
<div class="group relative bg-outfit-card rounded-xl overflow-hidden border border-outfit-border hover:border-purple-500 transition-all cursor-pointer">
  
  <!-- Image -->
  <div class="aspect-square overflow-hidden bg-white">
    <img src="item.jpg" class="w-full h-full object-cover group-hover:scale-105 transition-transform" />
  </div>

  <!-- Overlay Info (on hover) -->
  <div class="absolute inset-0 bg-gradient-to-t from-black/80 via-black/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex flex-col justify-end p-4">
    <div class="text-white font-medium mb-1">Navy Blazer</div>
    <div class="text-sm text-gray-300">Outerwear • Navy • Formal</div>
    
    <!-- Quick Actions -->
    <div class="flex gap-2 mt-3">
      <button class="px-3 py-1 bg-white/20 backdrop-blur rounded-lg text-xs text-white hover:bg-white/30 transition-colors">
        Edit
      </button>
      <button class="px-3 py-1 bg-purple-500 rounded-lg text-xs text-white hover:bg-purple-600 transition-colors">
        Use in Outfit
      </button>
    </div>
  </div>

</div>
```

### Outfit Builder Interface

**Layout**: Split-screen
- Left (40%): Wardrobe item selector with filters
- Right (60%): Canvas to build outfit

```html
<div class="h-screen flex">
  
  <!-- Left Sidebar: Wardrobe -->
  <div class="w-2/5 border-r border-outfit-border overflow-y-auto">
    
    <!-- Filters -->
    <div class="p-4 border-b border-outfit-border sticky top-0 bg-outfit-bg z-10">
      <div class="flex gap-2 mb-3">
        <button class="px-4 py-2 bg-purple-500 text-white rounded-lg text-sm">All</button>
        <button class="px-4 py-2 bg-outfit-card text-text-secondary rounded-lg text-sm hover:bg-outfit-card-hover">Tops</button>
        <button class="px-4 py-2 bg-outfit-card text-text-secondary rounded-lg text-sm hover:bg-outfit-card-hover">Bottoms</button>
        <button class="px-4 py-2 bg-outfit-card text-text-secondary rounded-lg text-sm hover:bg-outfit-card-hover">Shoes</button>
      </div>
      <input type="text" placeholder="Search wardrobe..." class="w-full px-4 py-2 bg-outfit-card border border-outfit-border rounded-lg text-white" />
    </div>

    <!-- Items Grid -->
    <div class="p-4 grid grid-cols-3 gap-3">
      <!-- Wardrobe item cards (smaller) -->
    </div>
  </div>

  <!-- Right Canvas: Outfit Builder -->
  <div class="flex-1 p-8">
    
    <!-- Header -->
    <div class="flex items-center justify-between mb-8">
      <h1 class="text-2xl font-bold text-white">Create New Outfit</h1>
      <div class="flex gap-3">
        <button class="btn-secondary">Cancel</button>
        <button class="btn-primary">Save Outfit</button>
      </div>
    </div>

    <!-- Outfit Canvas -->
    <div class="bg-outfit-card/50 border-2 border-dashed border-outfit-border rounded-2xl p-12 min-h-[600px] flex flex-col items-center justify-center">
      
      <!-- Empty State -->
      <div class="text-center text-text-muted">
        <svg class="w-16 h-16 mx-auto mb-4 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
        <p class="text-lg mb-2">Drag items here to build your outfit</p>
        <p class="text-sm">Or click an item from your wardrobe</p>
      </div>

      <!-- OR when items are added -->
      <div class="grid grid-cols-4 gap-6">
        <!-- Selected items displayed -->
      </div>
    </div>

    <!-- AI Suggestions (when items selected) -->
    <div class="mt-8 p-6 bg-purple-500/10 border border-purple-500/20 rounded-2xl">
      <div class="flex items-start gap-4">
        <div class="w-12 h-12 bg-purple-500 rounded-xl flex items-center justify-center flex-shrink-0">
          <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
          </svg>
        </div>
        <div>
          <h3 class="text-white font-medium mb-2">AI Suggestion</h3>
          <p class="text-text-secondary text-sm mb-3">
            This outfit works well! Consider adding a brown leather belt to tie the colors together.
          </p>
          <button class="text-purple-400 text-sm font-medium hover:text-purple-300">
            View Suggestions →
          </button>
        </div>
      </div>
    </div>

  </div>

</div>
```

---

## 🎨 Item Display Canvas

**Context**: You want items displayed in a specific visual style. Based on fashion app best practices:

### Item Card Design Principles

**Background Removal**:
- All clothing items should have transparent/removed backgrounds
- Display on clean white or subtle gradient backgrounds
- Shadow effects for depth (subtle drop shadow)

**Consistent Sizing**:
- All items scaled to fit within same aspect ratio (1:1 square recommended)
- Maintain aspect ratio (don't distort)
- Padding around edges for visual breathing room

**Visual Hierarchy**:
```html
<div class="relative aspect-square bg-white rounded-xl overflow-hidden shadow-lg">
  
  <!-- Item Image (background removed) -->
  <img 
    src="item-transparent.png" 
    alt="Navy Blazer"
    class="w-full h-full object-contain p-4"
  />

  <!-- Category Badge (top-left) -->
  <div class="absolute top-2 left-2 px-2 py-1 bg-black/60 backdrop-blur-sm rounded text-xs text-white">
    Outerwear
  </div>

  <!-- Favorite Icon (top-right) -->
  <button class="absolute top-2 right-2 w-8 h-8 bg-white/80 backdrop-blur-sm rounded-full flex items-center justify-center hover:bg-white transition-colors">
    <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
    </svg>
  </button>

  <!-- Color Indicator (bottom-left) -->
  <div class="absolute bottom-2 left-2 flex gap-1">
    <div class="w-4 h-4 rounded-full border-2 border-white shadow-sm" style="background-color: #1e3a8a;"></div>
  </div>

  <!-- Quick Action (bottom-right, on hover) -->
  <div class="absolute bottom-2 right-2 opacity-0 hover:opacity-100 transition-opacity">
    <button class="px-3 py-1 bg-purple-500 text-white text-xs rounded-full hover:bg-purple-600">
      Use
    </button>
  </div>

</div>
```

### Alternative: Polaroid Style

```html
<div class="bg-white rounded-lg shadow-xl p-3 transform hover:-rotate-1 transition-transform">
  
  <!-- Photo Area -->
  <div class="aspect-square bg-gray-50 rounded overflow-hidden mb-3">
    <img src="item.png" class="w-full h-full object-contain" />
  </div>

  <!-- Caption Area (like Polaroid bottom) -->
  <div class="text-center">
    <div class="font-handwriting text-gray-700 text-sm">Navy Blazer</div>
  </div>

</div>
```

---

## 🚀 Performance & Optimization

### Image Optimization

**Requirements**:
- WebP format with JPEG fallback
- Lazy loading for images below fold
- Responsive images (srcset)
- CDN delivery (Cloudflare/CloudFront)

```html
<picture>
  <source srcset="image-320.webp 320w, image-640.webp 640w, image-1024.webp 1024w" type="image/webp">
  <source srcset="image-320.jpg 320w, image-640.jpg 640w, image-1024.jpg 1024w" type="image/jpeg">
  <img 
    src="image-640.jpg" 
    alt="Description"
    loading="lazy"
    class="w-full h-auto"
  />
</picture>
```

### Animation Performance

**Use CSS transforms** (GPU-accelerated):
```css
/* Good - GPU accelerated */
.card {
  transform: translateY(0);
  transition: transform 0.3s ease;
}
.card:hover {
  transform: translateY(-4px);
}

/* Avoid - CPU rendering */
.card:hover {
  margin-top: -4px; /* Don't do this */
}
```

### Code Splitting

**Next.js**:
```javascript
// Dynamic imports for heavy components
const OutfitBuilder = dynamic(() => import('@/components/OutfitBuilder'), {
  loading: () => <LoadingSpinner />,
  ssr: false // Client-side only if needed
});
```

---

## 📱 Mobile Responsiveness

### Breakpoints

```css
/* Mobile First Approach */
/* Base styles: 320px+ */
.container { padding: 1rem; }

/* Small tablets: 640px+ */
@media (min-width: 640px) {
  .container { padding: 1.5rem; }
}

/* Tablets: 768px+ */
@media (min-width: 768px) {
  .container { padding: 2rem; }
}

/* Desktop: 1024px+ */
@media (min-width: 1024px) {
  .container { max-width: 1024px; margin: 0 auto; }
}

/* Large Desktop: 1280px+ */
@media (min-width: 1280px) {
  .container { max-width: 1280px; }
}
```

### Mobile Navigation

```html
<!-- Bottom Tab Bar (Mobile) -->
<nav class="md:hidden fixed bottom-0 left-0 right-0 bg-outfit-card border-t border-outfit-border z-50">
  <div class="flex justify-around items-center h-16">
    
    <a href="/dashboard" class="flex flex-col items-center justify-center flex-1 text-purple-500">
      <svg class="w-6 h-6 mb-1" fill="currentColor" viewBox="0 0 20 20">
        <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
      </svg>
      <span class="text-xs">Home</span>
    </a>

    <a href="/wardrobe" class="flex flex-col items-center justify-center flex-1 text-text-muted">
      <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
      </svg>
      <span class="text-xs">Wardrobe</span>
    </a>

    <!-- FAB (Floating Action Button) for Camera -->
    <button class="flex flex-col items-center justify-center flex-1 -mt-6">
      <div class="w-14 h-14 bg-gradient-primary rounded-full flex items-center justify-center shadow-lg">
        <svg class="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
      </div>
    </button>

    <a href="/outfits" class="flex flex-col items-center justify-center flex-1 text-text-muted">
      <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
      </svg>
      <span class="text-xs">Outfits</span>
    </a>

    <a href="/profile" class="flex flex-col items-center justify-center flex-1 text-text-muted">
      <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
      </svg>
      <span class="text-xs">Profile</span>
    </a>

  </div>
</nav>
```

### Touch Gestures

```javascript
// Swipe to delete (mobile wardrobe)
let startX, startY, distX, distY;

element.addEventListener('touchstart', (e) => {
  startX = e.touches[0].clientX;
  startY = e.touches[0].clientY;
});

element.addEventListener('touchmove', (e) => {
  distX = e.touches[0].clientX - startX;
  distY = e.touches[0].clientY - startY;
  
  if (Math.abs(distX) > Math.abs(distY)) {
    // Horizontal swipe
    element.style.transform = `translateX(${distX}px)`;
  }
});

element.addEventListener('touchend', () => {
  if (distX < -100) {
    // Swiped left - show delete
    showDeleteButton();
  } else {
    // Snap back
    element.style.transform = 'translateX(0)';
  }
});
```

---

## ♿ Accessibility (WCAG 2.1 AA)

### Color Contrast

**Requirements**:
- Text: 4.5:1 contrast ratio
- Large text (18pt+): 3:1 contrast ratio
- UI components: 3:1 contrast ratio

**Testing**: Use browser DevTools or [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

### Keyboard Navigation

```html
<!-- All interactive elements must be keyboard accessible -->
<button 
  class="btn-primary"
  aria-label="Start free trial"
  tabindex="0"
>
  Start Free Trial
</button>

<!-- Skip to main content -->
<a href="#main-content" class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-purple-500 text-white px-4 py-2 rounded">
  Skip to main content
</a>

<!-- Focus indicators (don't remove!) -->
<style>
  button:focus-visible,
  a:focus-visible {
    outline: 2px solid #8B5CF6;
    outline-offset: 2px;
  }
</style>
```

### Screen Reader Support

```html
<!-- Semantic HTML -->
<header role="banner">
  <nav role="navigation" aria-label="Main navigation">
    <!-- Navigation items -->
  </nav>
</header>

<main id="main-content" role="main">
  <!-- Main content -->
</main>

<!-- ARIA labels for icon-only buttons -->
<button aria-label="Close modal">
  <svg><!-- X icon --></svg>
</button>

<!-- Loading states -->
<div role="status" aria-live="polite" aria-label="Loading outfit suggestions">
  <svg class="animate-spin"><!-- Spinner --></svg>
</div>

<!-- Form labels (always associate) -->
<label for="email" class="block text-sm font-medium mb-2">
  Email Address
</label>
<input 
  id="email" 
  type="email" 
  aria-required="true"
  aria-describedby="email-error"
/>
<div id="email-error" class="text-red-500 text-sm mt-1" role="alert">
  <!-- Error message when validation fails -->
</div>
```

---

## 🔧 Technical Implementation Notes

### Tech Stack Confirmation

Based on `outfitmaker_overview.md`:

**Frontend**:
- Next.js 15 with React Server Components
- TypeScript
- Tailwind CSS
- Shadcn/UI components
- Zustand (state management)
- React Query (server state)

**Backend**:
- Next.js API routes (or Express.js)
- PostgreSQL + Prisma ORM
- Pinecone/Qdrant (vector search)
- NextAuth.js (authentication)

**AI Services**:
- FASHN AI (virtual try-on)
- Anthropic Claude 3.7 Sonnet (recommendations)
- Google Vertex AI (embeddings)
- YOLOv8 (clothing detection)

**Infrastructure**:
- Vercel (hosting)
- AWS S3/Cloudflare R2 (image storage)
- Redis (caching)

### File Structure Recommendation

```
outfitmaker/
├── app/                    # Next.js 15 app directory
│   ├── (auth)/
│   │   ├── signin/
│   │   ├── signup/
│   │   └── onboarding/    # Style quiz
│   ├── (dashboard)/
│   │   ├── dashboard/
│   │   ├── wardrobe/
│   │   ├── outfits/
│   │   └── profile/
│   ├── api/               # API routes
│   │   ├── auth/
│   │   ├── wardrobe/
│   │   ├── outfits/
│   │   └── ai/
│   ├── layout.tsx
│   └── page.tsx           # Landing page
├── components/
│   ├── ui/                # Shadcn components
│   ├── landing/           # Landing page sections
│   │   ├── Hero.tsx
│   │   ├── Features.tsx
│   │   ├── Demo.tsx
│   │   └── ...
│   ├── dashboard/
│   ├── wardrobe/
│   └── outfit-builder/
├── lib/
│   ├── ai/                # AI service integrations
│   ├── db/                # Prisma client
│   └── utils/
├── public/
│   ├── videos/
│   ├── images/
│   └── logo_option_4.svg
└── styles/
    └── globals.css
```

---

## 📊 Analytics & Tracking

### Events to Track

**Landing Page**:
- `landing_page_view`
- `hero_cta_click` (which button: trial vs demo)
- `feature_card_click`
- `video_play`
- `pricing_tier_select`

**Onboarding**:
- `quiz_start`
- `quiz_question_answer` (question_id, answer)
- `quiz_abandon` (on which question)
- `quiz_complete`

**Dashboard**:
- `wardrobe_item_add`
- `outfit_create`
- `outfit_suggestion_view`
- `outfit_suggestion_save`

**Implementation** (Mixpanel/Amplitude):
```typescript
// lib/analytics.ts
export const trackEvent = (eventName: string, properties?: Record<string, any>) => {
  if (typeof window !== 'undefined' && window.mixpanel) {
    window.mixpanel.track(eventName, properties);
  }
};

// Usage in components
trackEvent('hero_cta_click', {
  button_text: 'Start Free Trial',
  location: 'hero_section'
});
```

---

## 🎯 Conversion Optimization

### CTA Best Practices

**Primary CTAs**:
- Text: Action-oriented ("Start Free Trial" > "Sign Up")
- Color: High contrast gradient (purple/pink)
- Size: Large, prominent (min 44px touch target mobile)
- Placement: Above fold + repeated at key sections

**Secondary CTAs**:
- Text: Exploratory ("Watch Demo", "Learn More")
- Color: Outline or ghost button style
- Placement: Paired with primary CTA

### A/B Testing Recommendations

**Test Variables**:
1. Hero headline copy
2. CTA button text ("Start Free" vs "Get Started")
3. Video autoplay vs click-to-play
4. Quiz length (8 vs 10 questions)
5. Pricing visibility (show upfront vs hide until quiz)

---

## 🚦 Implementation Checklist

### Phase 1: Landing Page (Week 1-2)
- [ ] Set up Next.js 15 project with Tailwind CSS
- [ ] Configure dark/light mode with CSS variables
- [ ] Implement theme toggle component
- [ ] Implement navigation component
- [ ] Build hero section with video background
- [ ] Create social proof section
- [ ] Develop features grid (6 cards)
- [ ] Add product demo section
- [ ] Build "How It Works" timeline
- [ ] Implement testimonials section
- [ ] Create footer
- [ ] Test both themes (dark/light) for consistency
- [ ] Mobile responsive testing
- [ ] Accessibility audit

### Phase 2: Onboarding Flow (Week 3)
- [ ] Design style quiz UI
- [ ] Implement 10-question flow
- [ ] Add progress indicator
- [ ] Create question types (single/multi-select)
- [ ] Build results summary page
- [ ] Store quiz responses in database
- [ ] Generate user style profile

### Phase 3: Dashboard (Week 4-5)
- [ ] Create dashboard layout
- [ ] Build wardrobe grid component
- [ ] Implement item upload flow
- [ ] Add filtering/search functionality
- [ ] Create outfit builder interface
- [ ] Integrate AI outfit suggestions
- [ ] Add mobile bottom navigation

### Phase 4: Polish & Launch (Week 6)
- [ ] Performance optimization (images, code splitting)
- [ ] SEO optimization (meta tags, sitemap)
- [ ] Analytics integration
- [ ] Error tracking setup
- [ ] Cross-browser testing
- [ ] Final accessibility check
- [ ] Deploy to Vercel

---

## 📚 Additional Resources

### Design Inspiration
- Rizzle.ai - AI SaaS landing page aesthetic
- Codia AI - Dark theme with purple accents
- Midjourney - Clean, modern AI interface
- Notion - Card-based layouts
- Linear - Smooth animations

### Component Libraries
- Shadcn/UI: [ui.shadcn.com](https://ui.shadcn.com)
- Headless UI: [headlessui.com](https://headlessui.com)
- Radix UI: [radix-ui.com](https://radix-ui.com)

### Animation Libraries
- Framer Motion: React animations
- GSAP: Complex timeline animations
- Lottie: After Effects animations

### Icons
- Heroicons: [heroicons.com](https://heroicons.com)
- Lucide: [lucide.dev](https://lucide.dev)

---

## 📝 Final Notes for Claude Code

### Critical Points

1. **Dark/Light Mode Support**: App must support both themes with user preference toggle (dark mode is default)
2. **Purple/Pink Gradient**: Primary brand identity, use liberally
3. **Video Integration**: 3 videos provided must be integrated (hero, demo, features)
4. **Quiz is Essential**: Don't skip onboarding - it powers AI personalization
5. **Mobile Bottom Nav**: Critical for mobile UX (see mobile section)
6. **Accessibility**: Non-negotiable - follow WCAG 2.1 AA
7. **Performance**: Lazy load everything below fold, optimize images

### Questions to Ask Before Starting

1. Which video goes where? (Need user clarification on video placement)
2. Exact quiz questions finalized? (10 questions provided, confirm)
3. Payment integration needed in MVP? (Stripe setup)
4. Social login providers? (Google, Apple specified)

### Development Priority

**Must Have (Week 1-3)**:
- Landing page
- Dark/Light mode toggle with persistence
- Signup/signin
- Onboarding quiz
- Basic dashboard

**Should Have (Week 4-5)**:
- Wardrobe upload
- Outfit builder
- AI suggestions

**Nice to Have (Week 6+)**:
- Social features
- Advanced analytics
- Shopping integration

---

**End of UI/UX Guide**

This document serves as the complete reference for implementing OutfitMaker.ai's user interface. All design decisions, component specifications, and technical requirements are documented here. Update this guide as the product evolves.

**Version**: 1.0  
**Last Updated**: January 21, 2026  
**Maintained By**: Product Team
