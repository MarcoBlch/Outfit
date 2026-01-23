import { Controller } from "@hotwired/stimulus"

/**
 * Theme Toggle Controller
 *
 * Manages light/dark mode switching with:
 * - System preference detection
 * - localStorage persistence
 * - Smooth transitions
 * - ARIA accessibility support
 */
export default class extends Controller {
  static targets = ["icon", "label"]
  static values = {
    storageKey: { type: String, default: "outfit-theme" }
  }

  connect() {
    // Initialize theme from storage or system preference
    this.initializeTheme()

    // Listen for system preference changes
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.mediaQuery.addEventListener("change", this.handleSystemChange.bind(this))
  }

  disconnect() {
    if (this.mediaQuery) {
      this.mediaQuery.removeEventListener("change", this.handleSystemChange.bind(this))
    }
  }

  initializeTheme() {
    const savedTheme = localStorage.getItem(this.storageKeyValue)

    if (savedTheme) {
      // Use saved preference
      this.setTheme(savedTheme)
    } else {
      // Use system preference
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
      this.setTheme(prefersDark ? "dark" : "light")
    }
  }

  toggle() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === "dark" ? "light" : "dark"

    this.setTheme(newTheme)
    localStorage.setItem(this.storageKeyValue, newTheme)

    // Dispatch custom event for other components to react
    this.dispatch("changed", { detail: { theme: newTheme } })
  }

  setTheme(theme) {
    const html = document.documentElement

    if (theme === "dark") {
      html.classList.add("dark")
    } else {
      html.classList.remove("dark")
    }

    // Update icon if target exists
    this.updateIcon(theme)

    // Update ARIA attributes
    this.updateAriaAttributes(theme)

    // Update meta theme-color for mobile browsers
    this.updateMetaThemeColor(theme)
  }

  getCurrentTheme() {
    return document.documentElement.classList.contains("dark") ? "dark" : "light"
  }

  updateIcon(theme) {
    if (!this.hasIconTarget) return

    // SVG paths for sun and moon icons
    const sunIcon = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
      <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386-1.591 1.591M21 12h-2.25m-.386 6.364-1.591-1.591M12 18.75V21m-4.773-4.227-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z" />
    </svg>`

    const moonIcon = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
      <path stroke-linecap="round" stroke-linejoin="round" d="M21.752 15.002A9.72 9.72 0 0 1 18 15.75c-5.385 0-9.75-4.365-9.75-9.75 0-1.33.266-2.597.748-3.752A9.753 9.753 0 0 0 3 11.25C3 16.635 7.365 21 12.75 21a9.753 9.753 0 0 0 9.002-5.998Z" />
    </svg>`

    // Show opposite icon (sun when dark, moon when light)
    this.iconTarget.innerHTML = theme === "dark" ? sunIcon : moonIcon
  }

  updateAriaAttributes(theme) {
    this.element.setAttribute("aria-pressed", theme === "dark" ? "true" : "false")
    this.element.setAttribute("aria-label", theme === "dark" ? "Switch to light mode" : "Switch to dark mode")

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = theme === "dark" ? "Light mode" : "Dark mode"
    }
  }

  updateMetaThemeColor(theme) {
    let metaThemeColor = document.querySelector('meta[name="theme-color"]')

    if (!metaThemeColor) {
      metaThemeColor = document.createElement("meta")
      metaThemeColor.name = "theme-color"
      document.head.appendChild(metaThemeColor)
    }

    metaThemeColor.content = theme === "dark" ? "#0F0F0F" : "#FAFAFA"
  }

  handleSystemChange(event) {
    // Only react to system changes if user hasn't set a preference
    const savedTheme = localStorage.getItem(this.storageKeyValue)

    if (!savedTheme) {
      this.setTheme(event.matches ? "dark" : "light")
    }
  }
}
