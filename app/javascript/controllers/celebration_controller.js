import { Controller } from "@hotwired/stimulus"

// Celebration controller for milestone achievement modals
// Shows a celebratory modal with confetti animation
export default class extends Controller {
  static targets = ["container", "backdrop", "confetti"]
  static values = {
    milestone: String
  }

  connect() {
    // Check if this milestone was already celebrated
    const key = `milestone_celebrated_${this.milestoneValue}`
    if (!localStorage.getItem(key)) {
      this.show()
      localStorage.setItem(key, "true")
    }
  }

  show() {
    this.containerTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    // Auto-dismiss after 10 seconds
    this.autoDismissTimeout = setTimeout(() => {
      this.dismiss()
    }, 10000)
  }

  dismiss() {
    if (this.autoDismissTimeout) {
      clearTimeout(this.autoDismissTimeout)
    }
    this.containerTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
}
