import { Controller } from "@hotwired/stimulus"

// Dismissable controller for hiding elements and remembering the dismissal
export default class extends Controller {
  static values = {
    key: String
  }

  connect() {
    // Check if already dismissed
    if (this.hasBeenDismissed()) {
      this.element.remove()
    }
  }

  dismiss() {
    this.markAsDismissed()
    this.element.remove()
  }

  hasBeenDismissed() {
    return localStorage.getItem(this.keyValue) === "true"
  }

  markAsDismissed() {
    localStorage.setItem(this.keyValue, "true")
  }
}
