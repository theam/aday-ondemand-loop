import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['button', 'field', 'link']
    // enableOnSelect default is false

    connect() {
        document.addEventListener('select-project:change', this.handleProjectChange.bind(this))
    }
    disconnect() {
        document.removeEventListener('select-project:change', this.handleProjectChange.bind(this))
    }

    handleProjectChange(event) {
        const { projectId, projectName, projectPath } = event.detail
        const enabled = !!projectId

        if (this.hasButtonTarget) {
            this.buttonTarget.disabled = !enabled
        }

        if (this.hasFieldTarget) {
            this.fieldTarget.value = projectName || ''
        }

        if (this.hasLinkTarget) {
            const hasPath = !!projectName && !!projectPath

            this.linkTarget.href = hasPath ? projectPath : '#'
            this.linkTarget.classList.toggle('disabled', !hasPath)
            this.linkTarget.setAttribute('aria-disabled', String(!hasPath))
        }
    }
}
