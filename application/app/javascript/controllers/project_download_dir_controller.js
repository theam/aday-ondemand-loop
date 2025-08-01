import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal", "path", "form"]
    static values = { browserId: String }

    connect() {
        this.modalInstance = bootstrap.Modal.getOrCreateInstance(this.modalTarget)
        this.boundUpdate = this.updatePathFromEvent.bind(this)
        if (this.browserIdValue) {
            document.addEventListener(`file-browser:path-change:${this.browserIdValue}`, this.boundUpdate)
        }
    }

    disconnect() {
        if (this.browserIdValue) {
            document.removeEventListener(`file-browser:path-change:${this.browserIdValue}`, this.boundUpdate)
        }
    }

    open(event) {
        if (event) event.preventDefault()
        this.modalInstance.show()
    }

    updatePathFromEvent(event) {
        const path = event.detail.path
        if (this.hasPathTarget) this.pathTarget.value = path
    }

    select(event) {
        if (event) event.preventDefault()
        const browser = document.getElementById(this.browserIdValue)
        if (browser) {
            const input = browser.querySelector('[data-file-browser-target="pathInput"]')
            if (input) this.pathTarget.value = input.value
        }
        this.formTarget.requestSubmit()
    }
}
