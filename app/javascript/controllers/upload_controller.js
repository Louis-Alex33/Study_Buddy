import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileName"]

  connect() {
    console.log("✅ Upload controller connected")
  }

  handleFileSelect(event) {
    const input = event.target
    const fileName = input.files[0]?.name || "Aucun fichier sélectionné"

    console.log("📁 File selected:", fileName)
    console.log("📏 File size:", input.files[0]?.size, "bytes")

    if (this.hasFileNameTarget) {
      this.fileNameTarget.textContent = fileName
      console.log("✅ File name updated in UI")
    } else {
      console.error("❌ fileName target not found")
    }
  }
}
