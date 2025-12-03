# Implementation Plan: Frontend MVP & AI Integration

## Goal Description
Build a premium, responsive frontend for Outfit Maker and integrate Vertex AI for auto-tagging wardrobe items.

## User Review Required
- **Tech Stack**: Rails + Hotwire + TailwindCSS.
- **AI Flow**: Asynchronous processing with Sidekiq + Turbo Streams for real-time updates.

## Proposed Changes

### 1. Foundation & Design System (Completed)
*   Tailwind v4 Setup with Premium Dark Mode.
*   Core Layouts (Navbar, Flash).
*   UI Components (Button, Card).

### 2. Wardrobe Management (Completed)
*   Grid Layout & Filtering.
*   Drag-and-Drop Upload.

### 3. AI Integration (Auto-Tagging) [NEW]
*   **Job**: `app/jobs/image_analysis_job.rb`
    *   Input: `wardrobe_item_id`
    *   Action: Calls `ImageAnalysisService`
    *   Output: Updates `category`, `color`, `metadata` (tags, description)
    *   Feedback: Broadcasts `replace` to `wardrobe_item_{id}` via Turbo Streams.
*   **Controller**: `WardrobeItemsController#create`
    *   Enqueue `ImageAnalysisJob` after successful save.
*   **View**: `_wardrobe_item.html.erb`
    *   Add visual indicator (spinner/badge) when `category` is missing or "processing".
    *   Ensure partial uses `dom_id(wardrobe_item)` for Turbo Stream targeting.

### 4. Outfit Studio (Completed)
*   Split-Screen Layout.
*   Drag-and-Drop Canvas.

### 5. Dashboard (Completed)
*   Home Page with Recent Activity.

## Verification Plan
### Manual Verification
1.  **AI Flow**:
    *   Upload an image (e.g., a red t-shirt).
    *   Observe the card appear immediately with a "Processing..." state.
    *   Wait a few seconds.
    *   Verify the card automatically updates (without reload) to show "T-Shirt" and "Red".
    *   Check `metadata` in Rails console to confirm tags/description are saved.
