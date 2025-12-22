import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "openIcon", "closeIcon"]

  connect() {
    // Ensure menu is hidden on load
    this.close()
  }

  toggle() {
    if (this.menuTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove('hidden')
    if (this.hasOpenIconTarget) {
      this.openIconTarget.classList.add('hidden')
    }
    if (this.hasCloseIconTarget) {
      this.closeIconTarget.classList.remove('hidden')
    }
    // Prevent body scrolling when menu is open
    document.body.style.overflow = 'hidden'
  }

  close() {
    this.menuTarget.classList.add('hidden')
    if (this.hasOpenIconTarget) {
      this.openIconTarget.classList.remove('hidden')
    }
    if (this.hasCloseIconTarget) {
      this.closeIconTarget.classList.add('hidden')
    }
    // Restore body scrolling
    document.body.style.overflow = ''
  }

  // Close menu when clicking a link
  closeOnLinkClick(event) {
    // Small delay to allow navigation to complete
    setTimeout(() => this.close(), 100)
  }
}
