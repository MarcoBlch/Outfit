import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scroll-animation"
export default class extends Controller {
  connect() {
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add("opacity-100", "translate-y-0")
          entry.target.classList.remove("opacity-0", "translate-y-8")
        }
      })
    }, {
      threshold: 0.1,
      rootMargin: "0px 0px -100px 0px"
    })

    // Find all elements marked for scroll animation
    this.element.querySelectorAll('[data-scroll-animate]').forEach(el => {
      // Set initial state
      el.classList.add("opacity-0", "translate-y-8", "transition-all", "duration-700", "ease-out")
      this.observer.observe(el)
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}
