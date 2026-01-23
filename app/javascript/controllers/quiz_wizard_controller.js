import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "progressBar", "progressText", "backButton", "nextButton", "skipButton", "submitButton"]
  static values = {
    currentStep: { type: Number, default: 0 },
    totalSteps: { type: Number, default: 10 }
  }

  connect() {
    // Load saved progress from localStorage
    this.loadProgress()
    this.showCurrentStep()
    this.updateProgress()
    this.updateButtons()

    // Auto-save on any input change
    this.element.addEventListener('input', () => this.saveProgress())
    this.element.addEventListener('change', () => this.saveProgress())
  }

  disconnect() {
    // Clean up saved progress after successful submission
    if (this.element.dataset.submitted === 'true') {
      localStorage.removeItem('quiz_progress')
    }
  }

  next(event) {
    event.preventDefault()

    // Validate current step before proceeding
    if (!this.validateCurrentStep()) {
      this.showValidationError()
      return
    }

    // Clear any validation errors
    this.clearValidationError()

    // Move to next step
    if (this.currentStepValue < this.totalStepsValue - 1) {
      this.currentStepValue++
      this.showCurrentStep()
      this.updateProgress()
      this.updateButtons()
      this.saveProgress()
      this.scrollToTop()
    }
  }

  back(event) {
    event.preventDefault()

    if (this.currentStepValue > 0) {
      this.currentStepValue--
      this.showCurrentStep()
      this.updateProgress()
      this.updateButtons()
      this.scrollToTop()
    }
  }

  skip(event) {
    event.preventDefault()

    // Only allow skipping for optional questions
    const currentStep = this.stepTargets[this.currentStepValue]
    if (currentStep.dataset.optional === 'true') {
      this.next(event)
    }
  }

  goToStep(event) {
    event.preventDefault()
    const stepNumber = parseInt(event.currentTarget.dataset.step)

    if (stepNumber >= 0 && stepNumber < this.totalStepsValue) {
      this.currentStepValue = stepNumber
      this.showCurrentStep()
      this.updateProgress()
      this.updateButtons()
      this.scrollToTop()
    }
  }

  showCurrentStep() {
    this.stepTargets.forEach((step, index) => {
      if (index === this.currentStepValue) {
        step.classList.remove('hidden')
        step.classList.add('animate-fade-in')
      } else {
        step.classList.add('hidden')
        step.classList.remove('animate-fade-in')
      }
    })
  }

  updateProgress() {
    const percentage = ((this.currentStepValue + 1) / this.totalStepsValue) * 100

    // Update progress bar
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percentage}%`
    }

    // Update progress text
    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = `${this.currentStepValue + 1} of ${this.totalStepsValue}`
    }
  }

  updateButtons() {
    const isFirstStep = this.currentStepValue === 0
    const isLastStep = this.currentStepValue === this.totalStepsValue - 1
    const currentStep = this.stepTargets[this.currentStepValue]
    const isOptional = currentStep.dataset.optional === 'true'

    // Back button
    if (this.hasBackButtonTarget) {
      if (isFirstStep) {
        this.backButtonTarget.classList.add('invisible')
      } else {
        this.backButtonTarget.classList.remove('invisible')
      }
    }

    // Next button
    if (this.hasNextButtonTarget) {
      if (isLastStep) {
        this.nextButtonTarget.classList.add('hidden')
      } else {
        this.nextButtonTarget.classList.remove('hidden')
      }
    }

    // Submit button
    if (this.hasSubmitButtonTarget) {
      if (isLastStep) {
        this.submitButtonTarget.classList.remove('hidden')
      } else {
        this.submitButtonTarget.classList.add('hidden')
      }
    }

    // Skip button
    if (this.hasSkipButtonTarget) {
      if (isOptional && !isLastStep) {
        this.skipButtonTarget.classList.remove('hidden')
      } else {
        this.skipButtonTarget.classList.add('hidden')
      }
    }
  }

  validateCurrentStep() {
    const currentStep = this.stepTargets[this.currentStepValue]
    const isOptional = currentStep.dataset.optional === 'true'

    // Skip validation for optional steps
    if (isOptional) {
      return true
    }

    // Check for required radio buttons
    const radioGroups = currentStep.querySelectorAll('input[type="radio"]')
    if (radioGroups.length > 0) {
      const radioNames = new Set()
      radioGroups.forEach(radio => radioNames.add(radio.name))

      for (const name of radioNames) {
        const checked = currentStep.querySelector(`input[name="${name}"]:checked`)
        if (!checked) {
          return false
        }
      }
    }

    // Check for required checkboxes (at least one must be checked)
    const checkboxContainers = currentStep.querySelectorAll('[data-quiz-wizard-target="checkboxGroup"]')
    if (checkboxContainers.length > 0) {
      for (const container of checkboxContainers) {
        const checkboxes = container.querySelectorAll('input[type="checkbox"]:checked')
        if (checkboxes.length === 0) {
          return false
        }
      }
    }

    // Check for required text fields
    const requiredInputs = currentStep.querySelectorAll('input[type="text"][required], input[type="email"][required], textarea[required]')
    for (const input of requiredInputs) {
      if (!input.value.trim()) {
        return false
      }
    }

    return true
  }

  showValidationError() {
    const currentStep = this.stepTargets[this.currentStepValue]
    const errorContainer = currentStep.querySelector('[data-quiz-wizard-target="validationError"]')

    if (errorContainer) {
      errorContainer.classList.remove('hidden')
      errorContainer.classList.add('animate-shake')

      // Remove shake animation after it completes
      setTimeout(() => {
        errorContainer.classList.remove('animate-shake')
      }, 500)
    }
  }

  clearValidationError() {
    const currentStep = this.stepTargets[this.currentStepValue]
    const errorContainer = currentStep.querySelector('[data-quiz-wizard-target="validationError"]')

    if (errorContainer) {
      errorContainer.classList.add('hidden')
    }
  }

  saveProgress() {
    const formData = new FormData(this.element)
    const progress = {
      currentStep: this.currentStepValue,
      data: Object.fromEntries(formData.entries()),
      timestamp: Date.now()
    }

    localStorage.setItem('quiz_progress', JSON.stringify(progress))
  }

  loadProgress() {
    const saved = localStorage.getItem('quiz_progress')

    if (!saved) return

    try {
      const progress = JSON.parse(saved)

      // Only restore if saved within last 24 hours
      const hoursSinceUpdate = (Date.now() - progress.timestamp) / (1000 * 60 * 60)
      if (hoursSinceUpdate > 24) {
        localStorage.removeItem('quiz_progress')
        return
      }

      // Restore current step
      this.currentStepValue = progress.currentStep || 0

      // Restore form values
      Object.entries(progress.data).forEach(([name, value]) => {
        const input = this.element.querySelector(`[name="${name}"]`)
        if (input) {
          if (input.type === 'checkbox' || input.type === 'radio') {
            const specificInput = this.element.querySelector(`[name="${name}"][value="${value}"]`)
            if (specificInput) {
              specificInput.checked = true
            }
          } else {
            input.value = value
          }
        }
      })
    } catch (e) {
      console.error('Error loading quiz progress:', e)
      localStorage.removeItem('quiz_progress')
    }
  }

  scrollToTop() {
    // Smooth scroll to top of form
    this.element.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }

  // Handle form submission
  submit(event) {
    // Validate the last step
    if (!this.validateCurrentStep()) {
      event.preventDefault()
      this.showValidationError()
      return
    }

    // Mark as submitted so we clean up localStorage on disconnect
    this.element.dataset.submitted = 'true'

    // Let the form submit naturally
  }
}
