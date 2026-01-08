import { Controller } from "@hotwired/stimulus"

// Password toggle visibility controller
export default class extends Controller {
  static targets = [
    "password",
    "passwordConfirmation",
    "eyeIcon",
    "eyeOffIcon",
    "eyeIconConfirmation",
    "eyeOffIconConfirmation"
  ]

  toggle() {
    const input = this.passwordTarget
    const isPassword = input.type === "password"

    input.type = isPassword ? "text" : "password"
    this.eyeIconTarget.classList.toggle("hidden")
    this.eyeOffIconTarget.classList.toggle("hidden")
  }

  toggleConfirmation() {
    const input = this.passwordConfirmationTarget
    const isPassword = input.type === "password"

    input.type = isPassword ? "text" : "password"
    this.eyeIconConfirmationTarget.classList.toggle("hidden")
    this.eyeOffIconConfirmationTarget.classList.toggle("hidden")
  }
}
