import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="handle-modal"
export default class extends Controller {
  static targets = ["modal", "form", "closeButton"]

  closeAndReset(event) {
    this.closeButtonTarget.click();
    this.formTarget.reset()
  }
}
