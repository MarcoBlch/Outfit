import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["container", "backdrop", "panel"]
    static values = { open: Boolean, autoOpen: Boolean }

    connect() {
        // Close on ESC
        this.keydownHandler = (e) => {
            if (e.key === "Escape") this.close()
        }
        document.addEventListener("keydown", this.keydownHandler)

        if (this.autoOpenValue) {
            this.open()
        }
    }

    disconnect() {
        document.removeEventListener("keydown", this.keydownHandler)
    }

    open() {
        this.containerTarget.classList.remove("hidden")
        // Small delay to allow display:block to apply before opacity transition
        setTimeout(() => {
            this.backdropTarget.classList.remove("opacity-0")
            this.panelTarget.classList.remove("opacity-0", "translate-y-4", "sm:translate-y-0", "sm:scale-95")
        }, 10)
    }

    close() {
        this.backdropTarget.classList.add("opacity-0")
        this.panelTarget.classList.add("opacity-0", "translate-y-4", "sm:translate-y-0", "sm:scale-95")

        // Wait for transition to finish before hiding
        setTimeout(() => {
            this.containerTarget.classList.add("hidden")
            // If this modal was opened via Turbo Frame, navigate back to root
            if (this.element.parentElement.tagName === "TURBO-FRAME") {
                this.element.parentElement.src = null
                this.element.remove()
                // Always navigate to root when closing modals
                window.Turbo.visit('/')
            }
        }, 300)
    }

    // Close when clicking backdrop
    closeBackground(e) {
        if (e.target === this.backdropTarget) {
            this.close()
        }
    }
}
