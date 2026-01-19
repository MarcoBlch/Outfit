import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Listen for escape key to close modal
    this.escapeHandler = this.handleEscape.bind(this)
    document.addEventListener('keydown', this.escapeHandler)
  }

  disconnect() {
    document.removeEventListener('keydown', this.escapeHandler)
  }

  open(event) {
    event.preventDefault()
    const modal = document.getElementById('video-modal')
    if (modal) {
      modal.classList.remove('hidden')
      // Prevent body scroll when modal is open
      document.body.style.overflow = 'hidden'
    }
  }

  close(event) {
    event.preventDefault()
    const modal = document.getElementById('video-modal')
    if (modal) {
      modal.classList.add('hidden')
      // Restore body scroll
      document.body.style.overflow = ''

      // Stop video playback by resetting iframe src
      const iframe = modal.querySelector('iframe')
      if (iframe) {
        const src = iframe.src
        iframe.src = ''
        iframe.src = src
      }
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      const modal = document.getElementById('video-modal')
      if (modal && !modal.classList.contains('hidden')) {
        this.close(event)
      }
    }
  }
}
