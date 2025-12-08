import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    const savedTheme = localStorage.getItem('theme') || 'light'
    document.body.setAttribute('data-theme', savedTheme)
    this.updateIcon(savedTheme)
  }

  toggle() {
    const currentTheme = document.body.getAttribute('data-theme')
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark'

    document.body.setAttribute('data-theme', newTheme)
    localStorage.setItem('theme', newTheme)
    this.updateIcon(newTheme)
  }

  updateIcon(theme) {
    if (this.hasButtonTarget) {
      const icon = this.buttonTarget.querySelector('i')
      if (icon) {
        icon.className = theme === 'dark' ? 'fas fa-moon' : 'fas fa-sun'
      }
    }
  }
}
