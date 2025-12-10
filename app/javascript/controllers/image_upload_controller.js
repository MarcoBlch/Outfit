import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropzone", "placeholder", "preview", "previewImage", "fileName", "submit"]

  connect() {
    this.dragCounter = 0
  }

  click(event) {
    if (event.target === this.inputTarget) return
    this.inputTarget.click()
  }

  dragover(event) {
    event.preventDefault()
    this.dragCounter++
    this.dropzoneTarget.classList.add("border-purple-500", "bg-purple-500/10")
  }

  dragleave(event) {
    event.preventDefault()
    this.dragCounter--
    if (this.dragCounter === 0) {
      this.dropzoneTarget.classList.remove("border-purple-500", "bg-purple-500/10")
    }
  }

  drop(event) {
    event.preventDefault()
    this.dragCounter = 0
    this.dropzoneTarget.classList.remove("border-purple-500", "bg-purple-500/10")

    const files = event.dataTransfer.files
    if (files.length > 0 && this.isValidImage(files[0])) {
      this.inputTarget.files = files
      this.showPreview(files[0])
    }
  }

  preview(event) {
    const file = event.target.files[0]
    if (file && this.isValidImage(file)) {
      this.showPreview(file)
    }
  }

  showPreview(file) {
    const reader = new FileReader()
    reader.onload = (e) => {
      this.previewImageTarget.src = e.target.result
      this.fileNameTarget.textContent = file.name
      this.placeholderTarget.classList.add("hidden")
      this.previewTarget.classList.remove("hidden")
      this.submitTarget.disabled = false
    }
    reader.readAsDataURL(file)
  }

  isValidImage(file) {
    const validTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    const maxSize = 10 * 1024 * 1024 // 10MB

    if (!validTypes.includes(file.type)) {
      this.dispatch("toast", { detail: { message: "Please upload a valid image file (JPEG, PNG, GIF, or WebP)", type: "error" } })
      return false
    }

    if (file.size > maxSize) {
      this.dispatch("toast", { detail: { message: "Image must be smaller than 10MB", type: "error" } })
      return false
    }

    return true
  }
}
