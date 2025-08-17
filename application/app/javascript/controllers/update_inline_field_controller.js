import { Controller } from "@hotwired/stimulus"
import { showFlash } from 'utils/flash_message'

export default class extends Controller {
  static targets = ["display", "name", "form", "input"]
  static values = {
    fieldName: String,
    initialValue: String,
    url: String,
    errorMessage: String,
    type: String,
    method: String
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
    const requestType = this.hasTypeValue ? this.typeValue : "json"
    const method = this.hasMethodValue ? this.methodValue.toUpperCase() : "POST"
    if (requestType === "form") {
      this.submitForm(path, newValue, method)
    } else {
      this.submitJson(path, newValue, method)
    }
  }

  submitJson(path, newValue, method) {
    const csrfToken = window.loop_app_config.csrf_token
    fetch(path, {
      method: method,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": csrfToken,
        "X-Requested-With": "XMLHttpRequest"
      },
      credentials: "same-origin",
      body: JSON.stringify({ [this.fieldNameValue]: newValue })
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

  submitForm(path, newValue, method) {
    const form = document.createElement("form")
    form.method = "POST"
    form.action = path

    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = window.loop_app_config.csrf_token
    form.appendChild(csrfInput)

    if (method !== "POST") {
      const methodInput = document.createElement("input")
      methodInput.type = "hidden"
      methodInput.name = "_method"
      methodInput.value = method
      form.appendChild(methodInput)
    }

    const fieldInput = document.createElement("input")
    fieldInput.type = "hidden"
    fieldInput.name = this.fieldNameValue
    fieldInput.value = newValue
    form.appendChild(fieldInput)

    document.body.appendChild(form)
    form.submit()
  }

  cancel() {
    this.formTarget.classList.add("d-none")
    this.displayTarget.classList.remove("d-none")
    if (this.hasInitialValueValue) {
      this.inputTarget.value = this.initialValueValue
    }
  }
}
