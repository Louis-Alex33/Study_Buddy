import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {

    const loading = document.createElement('div')
    loading.className = 'flashcard-loading'
    loading.innerHTML = `
      <div class="flashcard-loading-content">
        <div class="wrapper">
          <div class="candles">
            <div class="light__wave"></div>
            <div class="candle1">
              <div class="candle1__body">
                <div class="candle1__eyes">
                  <span class="candle1__eyes-one"></span>
                  <span class="candle1__eyes-two"></span>
                </div>
                <div class="candle1__mouth"></div>
              </div>
              <div class="candle1__stick"></div>
            </div>

            <div class="candle2">
              <div class="candle2__body">
                <div class="candle2__eyes">
                  <div class="candle2__eyes-one"></div>
                  <div class="candle2__eyes-two"></div>
                </div>
              </div>
              <div class="candle2__stick"></div>
            </div>
            <div class="candle2__fire"></div>
            <div class="sparkles-one"></div>
            <div class="sparkles-two"></div>
            <div class="candle__smoke-one"></div>
            <div class="candle__smoke-two"></div>
          </div>
          <div class="floor"></div>
        </div>
        <h2 style="margin-top: 3rem; color: #2c3e50; font-size: 1.8rem; font-weight: 700;">
          <i class="fas fa-brain" style="color: #1351AA; margin-right: 0.5rem;"></i>
          Génération en cours
        </h2>
        <p>L'IA génère vos flashcards</p>
        <div style="margin-top: 1.5rem; color: #666; font-size: 0.9rem; opacity: 0.8;">
          <i class="fas fa-hourglass-half" style="margin-right: 0.3rem;"></i>
          Cela peut prendre quelques secondes...
        </div>
      </div>
    `
    document.body.appendChild(loading)

    const modal = bootstrap.Modal.getInstance(document.getElementById('generateFlashcardsModal'))
    if (modal) modal.hide()
  }
}
