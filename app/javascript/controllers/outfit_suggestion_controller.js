import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="outfit-suggestion"
export default class extends Controller {
  static targets = [
    "form",
    "input",
    "submitButton",
    "loadingState",
    "emptyState",
    "errorState",
    "resultsContainer",
    "remainingCount"
  ]

  static values = {
    remaining: Number
  }

  connect() {
    console.log("OutfitSuggestion controller connected")
    this.progressMessages = [
      "Analyzing your wardrobe...",
      "Understanding the context...",
      "Matching items with occasion...",
      "Generating outfit combinations...",
      "Finalizing suggestions..."
    ]
    this.messageIndex = 0
    this.messageInterval = null
  }

  disconnect() {
    this.stopProgressMessages()
  }

  // Handle form submission
  submit(event) {
    event.preventDefault()

    // Check if user has remaining suggestions
    if (this.remainingValue <= 0) {
      this.showRateLimitReached()
      return
    }

    // Validate input
    const context = this.inputTarget.value.trim()
    if (!context) {
      this.showError("Please describe an occasion or context")
      return
    }

    // Start loading state
    this.startLoading()

    // Submit the form via Turbo
    this.formTarget.requestSubmit()
  }

  // Handle keyboard shortcuts (Cmd/Ctrl + Enter to submit)
  handleKeydown(event) {
    if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
      event.preventDefault()
      this.submit(event)
    }
  }

  // Start loading state with progress messages
  startLoading() {
    // Disable submit button
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.textContent = "Generating..."

    // Hide empty and error states
    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.add("hidden")
    }
    if (this.hasErrorStateTarget) {
      this.errorStateTarget.classList.add("hidden")
    }

    // Show loading state
    if (this.hasLoadingStateTarget) {
      this.loadingStateTarget.classList.remove("hidden")
      this.startProgressMessages()
    }
  }

  // Stop loading state
  stopLoading() {
    // Re-enable submit button
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.textContent = "Generate Suggestions"
    }

    // Hide loading state
    if (this.hasLoadingStateTarget) {
      this.loadingStateTarget.classList.add("hidden")
      this.stopProgressMessages()
    }
  }

  // Cycle through progress messages
  startProgressMessages() {
    this.messageIndex = 0
    this.updateProgressMessage()

    // Update message every 1.5 seconds
    this.messageInterval = setInterval(() => {
      this.messageIndex = (this.messageIndex + 1) % this.progressMessages.length
      this.updateProgressMessage()
    }, 1500)
  }

  stopProgressMessages() {
    if (this.messageInterval) {
      clearInterval(this.messageInterval)
      this.messageInterval = null
    }
  }

  updateProgressMessage() {
    const messageElement = this.loadingStateTarget.querySelector("[data-progress-message]")
    if (messageElement) {
      messageElement.textContent = this.progressMessages[this.messageIndex]
    }
  }

  // Show error message
  showError(message) {
    if (this.hasErrorStateTarget) {
      this.errorStateTarget.innerHTML = `
        <div class="glass rounded-xl p-6 border border-red-500/20">
          <div class="flex items-start space-x-4">
            <div class="flex-shrink-0">
              <div class="inline-flex items-center justify-center w-10 h-10 bg-red-600/10 rounded-full">
                <svg class="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
              </div>
            </div>
            <div class="flex-1 space-y-2">
              <h3 class="text-lg font-semibold text-white">Error</h3>
              <p class="text-sm text-gray-300">${message}</p>
            </div>
          </div>
        </div>
      `
      this.errorStateTarget.classList.remove("hidden")
    }

    this.stopLoading()
  }

  // Show rate limit reached state
  showRateLimitReached() {
    if (this.hasResultsContainerTarget) {
      // The rate limit partial will be rendered by the server via Turbo Stream
      // This is just a client-side check to prevent unnecessary requests
      alert("You've reached your daily limit. Please upgrade for more suggestions.")
    }
  }

  // Update remaining count (called when Turbo Stream updates the count)
  updateRemainingCount(count) {
    this.remainingValue = count
    if (this.hasRemainingCountTarget) {
      this.remainingCountTarget.textContent = count
    }
  }

  // Handle successful response (called via Turbo Stream)
  handleSuccess() {
    this.stopLoading()

    // Update remaining count
    const newCount = Math.max(0, this.remainingValue - 1)
    this.updateRemainingCount(newCount)

    // Scroll to results
    if (this.hasResultsContainerTarget) {
      this.resultsContainerTarget.scrollIntoView({
        behavior: "smooth",
        block: "start"
      })
    }
  }

  // Handle error response (called via Turbo Stream or directly)
  handleError(message) {
    this.stopLoading()
    this.showError(message || "An unexpected error occurred. Please try again.")
  }
}
