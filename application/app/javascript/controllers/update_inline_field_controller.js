import { Controller } from "@hotwired/stimulus"
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
  static targets = ["display", "name", "form", "input"]
  static values = {
    fieldName: String,
    initialValue: String,
    url: String,
    errorMessage: String,
    type: String
  }

  connect() {
    if (this.hasInitialValueValue) {
      this.inputTarget.value = this.initialValueValue
    }
  }

  edit() {
    this.displayTarget.classList.add("d-none")
    this.formTarget.classList.remove("d-none")
    this.inputTarget.focus()
  }

  save() {
    const newValue = this.inputTarget.value.trim()
    if (!newValue || (this.hasInitialValueValue && newValue === this.initialValueValue)) {
      return this.cancel()
    }
    if (!this.hasFieldNameValue) {
      console.error('Field name not specified')
      return
    }

    const path = this.urlValue
    const csrfToken = window.loop_app_config.csrf_token

    const requestType = this.hasTypeValue ? this.typeValue : "json"
    const headers = {
      "X-CSRF-Token": csrfToken,
      "Accept": "application/json",
      "X-Requested-With": "XMLHttpRequest"
    }

    let body
    if (requestType === "form") {
      headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
      body = new URLSearchParams({ [this.fieldNameValue]: newValue }).toString()
    } else {
      headers["Content-Type"] = "application/json"
      body = JSON.stringify({ [this.fieldNameValue]: newValue })
    }

    fetch(path, {
      method: "PUT",
      headers: headers,
      credentials: "same-origin",
      body: body
    })
      .then(response => {
        if (!response.ok) throw new Error("Failed to update")
        return response.json()
      })
      .then(data => {
        this.nameTarget.textContent = newValue
        this.initialValueValue = newValue
        this.cancel()
      })
      .catch(error => {
        console.error(error)
        const message = this.hasErrorMessageValue ? this.errorMessageValue : 'Could not update field.'
        showFlash("error", message)
      })
  }

  cancel() {
    this.formTarget.classList.add("d-none")
    this.displayTarget.classList.remove("d-none")
    if (this.hasInitialValueValue) {
      this.inputTarget.value = this.initialValueValue
    }
  }
}
