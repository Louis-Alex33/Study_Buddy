import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "form", "input"]

  connect() {
    this.scrollToBottom()
    this.observeNewMessages()
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }

  observeNewMessages() {
    if (!this.hasMessagesTarget) return

    const observer = new MutationObserver(() => {
      this.scrollToBottom()
    })

    observer.observe(this.messagesTarget, {
      childList: true,
      subtree: true,
      characterData: true
    })
  }

  resetForm(event) {
    if (event.detail.success) {
      this.inputTarget.value = ""

      // Supprimer le placeholder vide si présent
      const emptyPlaceholder = document.getElementById("empty-chat-placeholder")
      if (emptyPlaceholder) {
        emptyPlaceholder.remove()
      }
    }
  }
}
