// app/javascript/controllers/select_files_project_controller.js
import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
    static targets = ['displayLabel']

    connect() {
        // DELAY UPDATE TO ALLOW OTHER CONTROLLERS TO CONNECT AND ADD LISTENERS
        requestAnimationFrame(() => {
            // On connect, try to find the first item in the dropdown list
            const firstLink = this.element.querySelector('[data-project-id]')
            if (firstLink) {
                this.updateDisplay(firstLink)
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

        this.updateDisplay(link)
        this.dispatchSelectedProject(projectId, projectName, projectPath)
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
}
