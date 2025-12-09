import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    const loading = document.createElement('div')
    loading.className = 'quiz-loading'
    loading.innerHTML = `
      <div class="quiz-loading-content">
        <div class="sea">
          <div class="circle-wrapper">
            <div class="bubble"></div>
            <div class="submarine-wrapper">
              <div class="submarine-body">
                <div class="window"></div>
                <div class="engine"></div>
                <div class="light"></div>
              </div>
              <div class="helix"></div>
              <div class="hat">
                <div class="leds-wrapper">
                  <div class="periscope"></div>
                  <div class="leds"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <h2>
          <i class="fas fa-brain" style="color: #1351AA; margin-right: 0.5rem;"></i>
          Génération du quiz
        </h2>
        <p>L'IA crée vos questions personnalisées</p>
        <div class="quiz-loading-hint">
          <i class="fas fa-hourglass-half"></i>
          Cela peut prendre quelques secondes...
        </div>
      </div>
    `
    document.body.appendChild(loading)

    const modal = bootstrap.Modal.getInstance(document.getElementById('uploadModal'))
    if (modal) modal.hide()
  }
}
