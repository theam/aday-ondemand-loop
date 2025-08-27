import { Controller } from "@hotwired/stimulus"
import { showFlash } from "utils/flash_message"

export default class extends Controller {
  static values = {
    url: String,
    modalId: String,
    title: String
  }

  show() {
    const modalElement = document.getElementById(this.modalIdValue)
    if (!modalElement) return
    const modalController = this.application.getControllerForElementAndIdentifier(modalElement, 'modal')
    if (!modalController) return

    if (modalController.hasTitleTarget && this.hasTitleValue) {
      modalController.titleTarget.innerText = this.titleValue
    }

    modalController.showSpinner()

    fetch(this.urlValue, { headers: { 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' } })
      .then(response => {
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)
        return response.json()
      })
      .then(events => {
        modalController.contentTarget.innerHTML = this.renderTable(events)
      })
      .catch(error => {
        console.error('Events load error', error)
        showFlash('error', window.loop_app_config.i18n.events.load.error, modalController.contentTarget)
      })
      .finally(() => {
        modalController.hideSpinner()
        const bsModal = bootstrap.Modal.getOrCreateInstance(modalElement)
        bsModal.show()
      })
  }

  renderTable(events) {
    const headers = window.loop_app_config.i18n.events.table
    if (!events.length) {
      return `<p class="mb-0">${headers.empty}</p>`
    }

    const rows = events.map(e => {
      const metadataItems = Object.entries(e.metadata || {}).map(([key, value]) => `<li><strong>${key}</strong>: ${value}</li>`).join('')
      const metadata = metadataItems ? `<ul class="list-unstyled mb-0">${metadataItems}</ul>` : ''
      return `<tr><td>${e.id}</td><td>${e.type}</td><td>${e.creation_date}</td><td>${metadata}</td></tr>`
    }).join('')

    return `\
<table class="table table-sm">\
  <thead>\
    <tr>\
      <th>${headers.header_id}</th>\
      <th>${headers.header_type}</th>\
      <th>${headers.header_creation_date}</th>\
      <th>${headers.header_metadata}</th>\
    </tr>\
  </thead>\
  <tbody>${rows}</tbody>\
</table>`
  }
}

