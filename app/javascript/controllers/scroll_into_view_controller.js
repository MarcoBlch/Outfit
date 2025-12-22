import { Controller } from "@hotwired/stimulus"

// Automatically scrolls an element into view when it appears in the DOM
// Used for showing generated outfit suggestions in the modal
export default class extends Controller {
  connect() {
    // Small delay to ensure the element is fully rendered
    setTimeout(() => {
      this.scrollIntoView()
    }, 100)
  }

  scrollIntoView() {
    // Scroll the element into view smoothly
    this.element.scrollIntoView({
      behavior: "smooth",
      block: "start",
      inline: "nearest"
    })

    // Add a subtle highlight animation
    this.element.classList.add("highlight-fade-in")

    // Remove the animation class after it completes
    setTimeout(() => {
      this.element.classList.remove("highlight-fade-in")
    }, 1000)
  }
}
