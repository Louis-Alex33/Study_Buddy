import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {

    const savedTheme = localStorage.getItem('theme') || 'light'
    document.body.setAttribute('data-theme', savedTheme)
    console.log('Dark mode controller connected, theme:', savedTheme)
  }

  toggle() {
    const currentTheme = document.body.getAttribute('data-theme')
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark'

    document.body.setAttribute('data-theme', newTheme)
    localStorage.setItem('theme', newTheme)
    console.log('Theme toggled to:', newTheme)
  }
}
