// app/javascript/controllers/select_project_controller.js
import { Controller } from '@hotwired/stimulus'
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
    static targets = ['displayLabel', 'spinner']

    connect() {
        // DELAY UPDATE TO ALLOW OTHER CONTROLLERS TO CONNECT AND ADD LISTENERS
        requestAnimationFrame(() => {
            // On connect, try to find the first item in the dropdown list
            const firstLink = this.element.querySelector('[data-project-id]')
            if (firstLink) {
                this.updateDisplay(firstLink)
                this.selectedProjectId = firstLink.dataset.projectId
                this.dispatchSelectedProject(firstLink.dataset.projectId, firstLink.dataset.projectName, firstLink.dataset.projectPath)
            }
        })
    }

    chooseProject(event) {
        event.preventDefault()
        const link = event.currentTarget
        const projectId = link.dataset.projectId
        const projectName = link.dataset.projectName
        const projectPath = link.dataset.projectPath

        if (projectId !== this.selectedProjectId) {
            this.showSpinner()
            this.setActiveProject(projectPath)
                .then(() => {
                    this.selectedProjectId = projectId
                    this.updateDisplay(link)
                    this.dispatchSelectedProject(projectId, projectName, projectPath)
                })
                .catch(error => {
                    const message = error?.error ?? window.loop_app_config.i18n.generic_server_error
                    showFlash('error', message)
                })
                .finally(() => {
                    this.hideSpinner()
                })
        } else {
            this.updateDisplay(link)
            this.dispatchSelectedProject(projectId, projectName, projectPath)
        }
    }

    setActiveProject(projectPath) {
        const csrfToken = window.loop_app_config.csrf_token
        return fetch(`${projectPath}/set_active`, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'X-CSRF-Token': csrfToken,
                'X-Requested-With': 'XMLHttpRequest'
            },
            credentials: 'same-origin'
        }).then(response => {
            if (!response.ok) return response.json().then(data => Promise.reject(data))
        })
    }

    updateDisplay(link) {
        const projectName = link.textContent.trim()
        if (this.hasDisplayLabelTarget) {
            this.displayLabelTarget.textContent = projectName
        }
    }

    dispatchSelectedProject(projectId, projectName, projectPath) {
        const customEvent = new CustomEvent('select-project:change', {
            detail: { projectId: projectId, projectName: projectName, projectPath: projectPath },
            bubbles: true
        })
        this.element.dispatchEvent(customEvent)
    }

    showSpinner() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.remove('d-none')
        }
    }

    hideSpinner() {
        if (this.hasSpinnerTarget) {
            this.spinnerTarget.classList.add('d-none')
        }
    }
}
