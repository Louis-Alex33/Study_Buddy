import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["statusSelect", "friendsSection"]

  connect() {
    this.toggleFriends()
  }

  toggleFriends() {
    const status = this.statusSelectTarget.value

    if (status === "shared") {
      this.friendsSectionTarget.style.display = "block"
    } else {
      this.friendsSectionTarget.style.display = "none"
      // Décocher tous les amis si on passe en public
      const checkboxes = this.friendsSectionTarget.querySelectorAll('input[type="checkbox"]')
      checkboxes.forEach(checkbox => checkbox.checked = false)
    }
  }
}
