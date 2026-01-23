import { Controller } from "@hotwired/stimulus"

// First-time user wizard controller
// Shows a welcome modal for new users with no wardrobe items
// Uses localStorage to track if the user has dismissed the wizard
export default class extends Controller {
  static targets = ["container", "backdrop"]
  static values = {
    dismissedKey: String
  }

  connect() {
    // Check if wizard should be shown
    if (!this.hasBeenDismissed()) {
      this.show()
    }
  }

  show() {
    this.containerTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
  }

  dismiss() {
    this.containerTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    this.markAsDismissed()
  }

  hasBeenDismissed() {
    return localStorage.getItem(this.dismissedKeyValue) === "true"
  }

  markAsDismissed() {
    localStorage.setItem(this.dismissedKeyValue, "true")
  }
}
