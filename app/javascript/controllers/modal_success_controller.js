import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
    static values = { redirectUrl: String }

    connect() {
        console.log('modal-success connected', this.redirectUrlValue)
        // Auto-close and redirect after 2 seconds
        this.timeout = setTimeout(() => {
            this.closeAndRedirect()
        }, 2000)
    }

    disconnect() {
        if (this.timeout) {
            clearTimeout(this.timeout)
        }
    }

    closeAndRedirect() {
        console.log('closeAndRedirect called')
        if (this.timeout) {
            clearTimeout(this.timeout)
        }

        // Navigate using Turbo with fallback
        if (this.redirectUrlValue) {
            // Try imported Turbo first, then window.Turbo, then fallback to location
            if (typeof Turbo !== 'undefined' && Turbo.visit) {
                Turbo.visit(this.redirectUrlValue)
            } else if (window.Turbo && window.Turbo.visit) {
                window.Turbo.visit(this.redirectUrlValue)
            } else {
                // Fallback to regular navigation
                window.location.href = this.redirectUrlValue
            }
        }
    }
}
