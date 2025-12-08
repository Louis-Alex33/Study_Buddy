import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "content"]

  switch(event) {
    const clickedButton = event.currentTarget
    const tabName = clickedButton.dataset.tab

    // Remove active class from all buttons
    this.buttonTargets.forEach(button => {
      button.classList.remove("active")
    })

    // Remove active class from all content
    this.contentTargets.forEach(content => {
      content.classList.remove("active")
    })

    // Add active class to clicked button
    clickedButton.classList.add("active")

    // Add active class to corresponding content
    const activeContent = this.contentTargets.find(
      content => content.dataset.tab === tabName
    )
    if (activeContent) {
      activeContent.classList.add("active")
    }
  }
}
