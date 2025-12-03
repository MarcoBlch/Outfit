# Tasks: Frontend MVP

## Phase 1: Foundation & Design System
- [x] **Setup & Configuration** <!-- id: 0 -->
    - [x] Verify TailwindCSS setup and configure premium color palette (HSL) <!-- id: 1 -->
    - [x] Install `heroicons` or similar icon set <!-- id: 2 -->
    - [x] Configure `importmap` or `jsbundling` for Stimulus controllers <!-- id: 3 -->
- [x] **Core Layout & Navigation** <!-- id: 4 -->
    - [x] Create `application.html.erb` with responsive structure <!-- id: 5 -->
    - [x] Build `_navbar.html.erb` with glassmorphism effect <!-- id: 6 -->
    - [x] Create `_flash.html.erb` for toast notifications <!-- id: 7 -->
- [x] **UI Components** <!-- id: 8 -->
    - [x] Build `Button` component (variants: primary, secondary, ghost) <!-- id: 9 -->
    - [x] Build `Card` component with hover effects <!-- id: 10 -->
    - [ ] Build `Modal` / `SlideOver` component (Stimulus-controlled) <!-- id: 11 -->

## Phase 2: Wardrobe Management
- [x] **Wardrobe Index (`/wardrobe_items`)** <!-- id: 12 -->
    - [x] Design Masonry/Grid layout for items <!-- id: 13 -->
    - [x] Implement Sidebar Filters (Category, Color) using Turbo Frames <!-- id: 14 -->
    - [x] Add Search Bar (Real-time filtering with Stimulus) <!-- id: 15 -->
- [x] **Upload Experience** <!-- id: 16 -->
    - [x] Create Drag-and-Drop Upload Zone (Stimulus) <!-- id: 17 -->
    - [x] Implement Image Preview before upload <!-- id: 18 -->
    - [x] Handle "Auto-Tagging" feedback (loading state while AI processes) <!-- id: 19 -->
- [ ] **Item Details** <!-- id: 20 -->
    - [ ] Create "Quick View" modal for item details <!-- id: 21 -->
    - [ ] Implement "Edit Metadata" form <!-- id: 22 -->

## Phase 3: Outfit Studio
- [x] **Studio Layout (`/outfits/new`)** <!-- id: 23 -->
    - [x] Build Split-Screen Layout (Wardrobe Sidebar vs. Canvas) <!-- id: 24 -->
- [x] **Canvas Interactivity** <!-- id: 25 -->
    - [x] Implement Drag-and-Drop from Sidebar to Canvas <!-- id: 26 -->
    - [x] Allow resizing/positioning of items (Basic implementation) <!-- id: 27 -->
- [ ] **Saving & Management** <!-- id: 28 -->
    - [x] Implement "Save Outfit" form (Name, Occasion) <!-- id: 29 -->
    - [ ] Build Outfit Index/Gallery view <!-- id: 30 -->

## Phase 4: Dashboard & Polish
- [x] **Dashboard** <!-- id: 31 -->
    - [x] Create `Pages#home` with "Outfit of the Day" and "Recent Items" <!-- id: 32 -->
- [x] **Final Polish** <!-- id: 33 -->
    - [x] Add micro-animations (hover states, transitions) <!-- id: 34 -->
    - [x] Ensure Mobile Responsiveness <!-- id: 35 -->
