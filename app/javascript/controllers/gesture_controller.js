import { Controller } from "@hotwired/stimulus"

// Utility controller for detecting and normalizing gestures
// Handles swipe direction, velocity, touch vs mouse events
export default class extends Controller {
  static values = {
    threshold: { type: Number, default: 50 }, // minimum distance for swipe
    velocityThreshold: { type: Number, default: 0.3 }, // minimum velocity
    preventMultiTouch: { type: Boolean, default: true }
  }

  connect() {
    this.touchStartX = 0
    this.touchStartY = 0
    this.touchEndX = 0
    this.touchEndY = 0
    this.startTime = 0
    this.touchStarted = false
  }

  // Get unified event coordinates (works for touch and mouse)
  getCoordinates(event) {
    if (event.type.includes('touch')) {
      const touch = event.touches[0] || event.changedTouches[0]
      return { x: touch.clientX, y: touch.clientY }
    }
    return { x: event.clientX, y: event.clientY }
  }

  // Handle touch/mouse start
  handleStart(event) {
    // Prevent multi-touch if configured
    if (this.preventMultiTouchValue && event.touches && event.touches.length > 1) {
      return
    }

    const coords = this.getCoordinates(event)
    this.touchStartX = coords.x
    this.touchStartY = coords.y
    this.startTime = Date.now()
    this.touchStarted = true

    // Dispatch custom event
    this.dispatch('start', {
      detail: { x: coords.x, y: coords.y, event }
    })
  }

  // Handle touch/mouse move
  handleMove(event) {
    if (!this.touchStarted) return

    const coords = this.getCoordinates(event)
    this.touchEndX = coords.x
    this.touchEndY = coords.y

    const deltaX = this.touchEndX - this.touchStartX
    const deltaY = this.touchEndY - this.touchStartY

    // Dispatch custom event with delta
    this.dispatch('move', {
      detail: {
        x: coords.x,
        y: coords.y,
        deltaX,
        deltaY,
        event
      }
    })
  }

  // Handle touch/mouse end
  handleEnd(event) {
    if (!this.touchStarted) return

    const coords = this.getCoordinates(event)
    this.touchEndX = coords.x
    this.touchEndY = coords.y
    const endTime = Date.now()

    const deltaX = this.touchEndX - this.touchStartX
    const deltaY = this.touchEndY - this.touchStartY
    const deltaTime = endTime - this.startTime
    const absX = Math.abs(deltaX)
    const absY = Math.abs(deltaY)

    // Calculate velocity (pixels per millisecond)
    const velocityX = Math.abs(deltaX / deltaTime)
    const velocityY = Math.abs(deltaY / deltaTime)

    // Determine swipe direction
    let direction = null
    let isSwipe = false

    if (absX > this.thresholdValue || absY > this.thresholdValue) {
      if (absX > absY) {
        // Horizontal swipe
        if (velocityX > this.velocityThresholdValue) {
          direction = deltaX > 0 ? 'right' : 'left'
          isSwipe = true
        }
      } else {
        // Vertical swipe
        if (velocityY > this.velocityThresholdValue) {
          direction = deltaY > 0 ? 'down' : 'up'
          isSwipe = true
        }
      }
    }

    // Dispatch end event
    this.dispatch('end', {
      detail: {
        x: coords.x,
        y: coords.y,
        deltaX,
        deltaY,
        direction,
        isSwipe,
        velocityX,
        velocityY,
        duration: deltaTime,
        event
      }
    })

    // Dispatch swipe event if detected
    if (isSwipe && direction) {
      this.dispatch('swipe', {
        detail: {
          direction,
          deltaX,
          deltaY,
          velocityX,
          velocityY,
          event
        }
      })

      // Dispatch direction-specific events
      this.dispatch(`swipe-${direction}`, {
        detail: {
          delta: direction === 'left' || direction === 'right' ? deltaX : deltaY,
          velocity: direction === 'left' || direction === 'right' ? velocityX : velocityY,
          event
        }
      })
    }

    this.touchStarted = false
  }

  // Cancel gesture
  handleCancel(event) {
    this.touchStarted = false
    this.dispatch('cancel', { detail: { event } })
  }

  // Action methods for easy Stimulus binding
  start(event) {
    this.handleStart(event)
  }

  move(event) {
    this.handleMove(event)
  }

  end(event) {
    this.handleEnd(event)
  }

  cancel(event) {
    this.handleCancel(event)
  }
}
