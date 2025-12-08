import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    completed: Number,
    total: Number,
    updateUrl: String
  }

  static targets = ["progressBar", "progressText", "answer"]

  connect() {
    this.completedQuestions = this.completedValue
    this.totalQuestions = this.totalValue
    this.answeredQuestions = new Set()

    if (this.completedQuestions > 0) {
      this.updateProgressDisplay()
    }
  }

  showAnswer(event) {
    const index = event.params.index
    const answerElement = this.answerTargets[index]

    if (answerElement) {
      answerElement.style.display = 'block'
    }

    if (!this.answeredQuestions.has(index)) {
      this.answeredQuestions.add(index)
      this.completedQuestions++
      this.updateProgressDisplay()
      this.saveProgress()
    }
  }

  updateProgressDisplay() {
    const percentage = Math.round((this.completedQuestions / this.totalQuestions) * 100)

    this.progressBarTarget.style.width = percentage + '%'
    this.progressBarTarget.setAttribute('aria-valuenow', percentage)
    this.progressBarTarget.textContent = percentage + '%'
    this.progressTextTarget.textContent = this.completedQuestions + ' / ' + this.totalQuestions + ' questions completees'

    if (this.completedQuestions === this.totalQuestions) {
      this.progressBarTarget.classList.remove('progress-bar-animated')
      this.progressBarTarget.classList.add('bg-success')
    }
  }

  saveProgress() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content

    fetch(this.updateUrlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({ progress: this.completedQuestions })
    })
  }
}
