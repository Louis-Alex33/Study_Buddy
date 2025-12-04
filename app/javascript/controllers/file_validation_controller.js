import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("File validation controller connected")
  }

  validate() {
    const fileInput = this.element.querySelector('input[type="file"]');
    const file = fileInput.files[0];
    
    if (file.size > 10 * 1024 * 1024) { // 10 MB limit
      document.querySelector(".lecture_document input").classList.add("is-invalid");
      document.querySelector(".lecture_document").insertAdjacentHTML("beforeend", '<div class="invalid-feedback">Document size must be less than 10MB</div>')
      fileInput.value = ""; // Clear the input
    } else {
      document.querySelector(".lecture_document input").classList.remove("is-invalid");
      const feedback = document.querySelector(".lecture_document .invalid-feedback");
      if (feedback) {
        feedback.remove();
      }
    }
  }
}
