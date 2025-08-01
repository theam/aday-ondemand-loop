import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["modal", "browser", "path", "form"]

    connect() {
        this.modalInstance = bootstrap.Modal.getOrCreateInstance(this.modalTarget)
        this.boundUpdate = this.updatePathFromEvent.bind(this)
        if (this.hasBrowserTarget) {
            const id = this.browserTarget.id
            document.addEventListener(`file-browser:path-change:${id}`, this.boundUpdate)
        }
    }

    disconnect() {
        if (this.hasBrowserTarget) {
            const id = this.browserTarget.id
            document.removeEventListener(`file-browser:path-change:${id}`, this.boundUpdate)
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
        // get current path from browser
        const input = this.browserTarget.querySelector('[data-file-browser-target="pathInput"]')
        if (input) this.pathTarget.value = input.value
        this.formTarget.requestSubmit()
    }
}
