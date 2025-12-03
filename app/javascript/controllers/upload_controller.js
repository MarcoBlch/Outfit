import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["input", "preview", "dropZone"]

    connect() {
        this.dropZoneTarget.addEventListener("dragover", this.handleDragOver.bind(this))
        this.dropZoneTarget.addEventListener("dragleave", this.handleDragLeave.bind(this))
        this.dropZoneTarget.addEventListener("drop", this.handleDrop.bind(this))
    }

    handleDragOver(e) {
        e.preventDefault()
        this.dropZoneTarget.classList.add("border-primary", "bg-primary/10")
    }

    handleDragLeave(e) {
        e.preventDefault()
        this.dropZoneTarget.classList.remove("border-primary", "bg-primary/10")
    }

    handleDrop(e) {
        e.preventDefault()
        this.dropZoneTarget.classList.remove("border-primary", "bg-primary/10")

        if (e.dataTransfer.files && e.dataTransfer.files[0]) {
            this.inputTarget.files = e.dataTransfer.files
            this.previewFile()
        }
    }

    select(e) {
        this.inputTarget.click()
    }

    previewFile() {
        const file = this.inputTarget.files[0]
        if (file) {
            const reader = new FileReader()
            reader.onload = (e) => {
                this.previewTarget.src = e.target.result
                this.previewTarget.classList.remove("hidden")
                this.dropZoneTarget.classList.add("hidden")
                // Auto submit form
                this.element.closest("form").requestSubmit()
            }
            reader.readAsDataURL(file)
        }
    }
}
