import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="product-recommendation"
// Handles analytics tracking for product recommendation views and clicks
export default class extends Controller {
  static values = {
    recommendationId: Number,
    suggestionId: Number,
    productUrl: String
  }

  connect() {
    console.log("ProductRecommendation controller connected", {
      recommendationId: this.recommendationIdValue,
      suggestionId: this.suggestionIdValue
    })
  }

  // Track when a product recommendation is viewed
  // Called automatically when the Turbo Frame loads
  trackView(event) {
    // Only track if we have valid IDs
    if (!this.hasRecommendationIdValue || !this.hasSuggestionIdValue) {
      console.warn("Missing recommendation or suggestion ID for view tracking")
      return
    }

    // Prevent duplicate tracking on the same recommendation
    if (this.element.dataset.viewTracked === "true") {
      return
    }

    console.log("Tracking product recommendation view", {
      recommendationId: this.recommendationIdValue,
      suggestionId: this.suggestionIdValue
    })

    // Mark as tracked to prevent duplicates
    this.element.dataset.viewTracked = "true"

    // Send analytics request
    this.sendAnalyticsRequest("record_view")
  }

  // Track when a user clicks on a product affiliate link
  trackClick(event) {
    // Don't prevent default - let the link open
    // But track the click first

    const recommendationId = event.currentTarget.dataset.productRecommendationRecommendationIdValue
    const suggestionId = event.currentTarget.dataset.productRecommendationSuggestionIdValue
    const productUrl = event.currentTarget.dataset.productRecommendationProductUrlValue

    if (!recommendationId || !suggestionId) {
      console.warn("Missing recommendation or suggestion ID for click tracking")
      return
    }

    console.log("Tracking product click", {
      recommendationId,
      suggestionId,
      productUrl
    })

    // Track in Plausible Analytics
    if (typeof window.plausible !== 'undefined') {
      window.plausible('Affiliate Click', {
        props: { url: productUrl }
      });
    }

    // Send analytics request (non-blocking, don't wait for response)
    this.sendAnalyticsRequest(
      "record_click",
      parseInt(recommendationId),
      parseInt(suggestionId)
    ).catch(error => {
      console.error("Failed to track click:", error)
    })
  }

  // Send analytics request to the server
  async sendAnalyticsRequest(action, recommendationId = null, suggestionId = null) {
    // Use provided IDs or fall back to controller values
    const recId = recommendationId || this.recommendationIdValue
    const sugId = suggestionId || this.suggestionIdValue

    if (!recId || !sugId) {
      console.error("Cannot send analytics request: missing IDs")
      return
    }

    // Build the URL
    const url = `/outfit_suggestions/${sugId}/recommendations/${recId}/${action}`

    try {
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getCSRFToken()
        },
        credentials: "same-origin"
      })

      if (!response.ok) {
        throw new Error(`Analytics request failed: ${response.status}`)
      }

      console.log(`Analytics ${action} tracked successfully`)
    } catch (error) {
      console.error(`Failed to track ${action}:`, error)
      // Don't throw - analytics failures should not break user experience
    }
  }

  // Get CSRF token from meta tag
  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.content : ""
  }
}
