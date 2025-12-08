import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    disconnect() {
        if (this.timeout) {
            clearTimeout(this.timeout)
        }
    }

    submit() {
        clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
            this.element.requestSubmit()
        }, 200)
    }
}
