# Tasks: Frontend MVP

## Phase 1: Foundation & Design System
- [ ] **Setup & Configuration** <!-- id: 0 -->
    - [ ] Verify TailwindCSS setup and configure premium color palette (HSL) <!-- id: 1 -->
    - [ ] Install `heroicons` or similar icon set <!-- id: 2 -->
    - [ ] Configure `importmap` or `jsbundling` for Stimulus controllers <!-- id: 3 -->
- [ ] **Core Layout & Navigation** <!-- id: 4 -->
    - [ ] Create `application.html.erb` with responsive structure <!-- id: 5 -->
    - [ ] Build `_navbar.html.erb` with glassmorphism effect <!-- id: 6 -->
    - [ ] Create `_flash.html.erb` for toast notifications <!-- id: 7 -->
- [ ] **UI Components** <!-- id: 8 -->
    - [ ] Build `Button` component (variants: primary, secondary, ghost) <!-- id: 9 -->
    - [ ] Build `Card` component with hover effects <!-- id: 10 -->
    - [ ] Build `Modal` / `SlideOver` component (Stimulus-controlled) <!-- id: 11 -->

## Phase 2: Wardrobe Management
- [ ] **Wardrobe Index (`/wardrobe_items`)** <!-- id: 12 -->
    - [ ] Design Masonry/Grid layout for items <!-- id: 13 -->
    - [ ] Implement Sidebar Filters (Category, Color) using Turbo Frames <!-- id: 14 -->
    - [ ] Add Search Bar (Real-time filtering with Stimulus) <!-- id: 15 -->
- [ ] **Upload Experience** <!-- id: 16 -->
    - [ ] Create Drag-and-Drop Upload Zone (Stimulus) <!-- id: 17 -->
    - [ ] Implement Image Preview before upload <!-- id: 18 -->
    - [ ] Handle "Auto-Tagging" feedback (loading state while AI processes) <!-- id: 19 -->
- [ ] **Item Details** <!-- id: 20 -->
    - [ ] Create "Quick View" modal for item details <!-- id: 21 -->
    - [ ] Implement "Edit Metadata" form <!-- id: 22 -->

## Phase 3: Outfit Studio
- [ ] **Studio Layout (`/outfits/new`)** <!-- id: 23 -->
    - [ ] Build Split-Screen Layout (Wardrobe Sidebar vs. Canvas) <!-- id: 24 -->
- [ ] **Canvas Interactivity** <!-- id: 25 -->
    - [ ] Implement Drag-and-Drop from Sidebar to Canvas <!-- id: 26 -->
    - [ ] Allow resizing/positioning of items (Basic implementation) <!-- id: 27 -->
- [ ] **Saving & Management** <!-- id: 28 -->
    - [ ] Implement "Save Outfit" form (Name, Occasion) <!-- id: 29 -->
    - [ ] Build Outfit Index/Gallery view <!-- id: 30 -->

## Phase 4: Dashboard & Polish
- [ ] **Dashboard** <!-- id: 31 -->
    - [ ] Create `Pages#home` with "Outfit of the Day" and "Recent Items" <!-- id: 32 -->
- [ ] **Final Polish** <!-- id: 33 -->
    - [ ] Add micro-animations (hover states, transitions) <!-- id: 34 -->
    - [ ] Ensure Mobile Responsiveness <!-- id: 35 -->
