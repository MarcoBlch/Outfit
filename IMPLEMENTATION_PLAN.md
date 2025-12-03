# Implementation Plan: Frontend MVP

## Goal Description
Build a premium, responsive, and interactive frontend for the Outfit Maker application using **Ruby on Rails 7**, **Hotwire (Turbo & Stimulus)**, and **TailwindCSS**. The design will focus on "Visual Excellence" with a dark-mode-first aesthetic, glassmorphism elements, and smooth animations.

## User Review Required
- **Tech Stack**: Confirmation of Rails + Hotwire + TailwindCSS (No React/Next.js).
- **Design Direction**: "Premium", Dark Mode, Glassmorphism.

## Proposed Changes

### 1. Foundation & Design System
*   **Tailwind Configuration**:
    *   Define a custom color palette in `tailwind.config.js` using CSS variables for flexibility (e.g., `--color-primary`, `--color-bg-glass`).
    *   Add plugins: `@tailwindcss/forms`, `@tailwindcss/typography`, `@tailwindcss/aspect-ratio`.
*   **Layouts**:
    *   `app/views/layouts/application.html.erb`: Main shell with a sticky, glassmorphism navbar.
    *   `app/views/shared/_navbar.html.erb`: Navigation links (Dashboard, Wardrobe, Studio).
    *   `app/views/shared/_flash.html.erb`: Animated toast notifications for success/error messages.

### 2. Wardrobe Management (`/wardrobe_items`)
*   **Controller**: Update `WardrobeItemsController` to support `format.html` and filtering params.
*   **Views**:
    *   `index.html.erb`: A responsive grid of `_wardrobe_item.html.erb` partials.
    *   **Turbo Frames**: Wrap the grid in a Turbo Frame (`id="wardrobe_grid"`) so filters (Category, Color) update only the grid without a full page reload.
    *   **Upload**: A "Floating Action Button" or prominent "Add Item" card that opens a modal or slide-over.
*   **Stimulus Controllers**:
    *   `upload_controller.js`: Handle drag-and-drop file selection and image preview.
    *   `filter_controller.js`: Debounce search input and submit filter forms automatically.

### 3. Outfit Studio (`/outfits/new`)
*   **Layout**: A specialized full-screen layout (hiding standard footer/nav if needed) for maximum workspace.
*   **Components**:
    *   **Sidebar**: A scrollable list of wardrobe items (draggable).
    *   **Canvas**: A drop zone area.
*   **Interactivity (Stimulus)**:
    *   `drag_controller.js`: Manage the drag-and-drop state.
    *   **Logic**: When an item is dropped on the canvas, create a hidden input field for `outfit[items_attributes][][wardrobe_item_id]` and `position_x/y`.
    *   *Note*: For MVP, we will start with simple "click to add" or basic drag-and-drop. Complex resizing/rotation will be Phase 3.

### 4. Dashboard (`/`)
*   **Controller**: Create `PagesController#home`.
*   **Views**:
    *   `home.html.erb`: A dashboard showing "Recent Uploads" and "Latest Outfits".
    *   **Empty State**: If no items, show a "Get Started" onboarding wizard (Step 1: Upload 5 items).

## Verification Plan
### Manual Verification
1.  **Design Check**: Verify the app looks "premium" (fonts, colors, spacing) on Desktop and Mobile.
2.  **Flow - Upload**:
    *   Go to Wardrobe -> Click Upload -> Select Image -> Verify it appears in the grid.
3.  **Flow - Filter**:
    *   Filter by "Tops" -> Verify only tops are shown (without page reload).
4.  **Flow - Create Outfit**:
    *   Go to Studio -> Drag items to canvas -> Click Save -> Verify redirected to Outfit Show page.

### Automated Tests
*   Ensure existing API tests (`verify_*.rb`) still pass (Backend regression check).
*   (Optional) Add System Tests (`spec/system`) for critical UI flows if time permits.
