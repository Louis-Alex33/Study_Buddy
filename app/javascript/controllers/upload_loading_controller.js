import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {

    const loading = document.createElement('div')
    loading.className = 'upload-loading'
    loading.innerHTML = `
      <div class="upload-loading-content">
        <div class="spinner">
          <div class="stickman">
            <div class="head"></div>
            <div class="body"></div>
            <div class="arm-left"></div>
            <div class="arm-right"></div>
            <div class="leg-left"></div>
            <div class="leg-right"></div>
          </div>
          <div class="ground"></div>
        </div>
        <h2 style="margin-top: 3rem; color: #2c3e50; font-size: 1.8rem; font-weight: 700;">
          <i class="fas fa-brain" style="color: #1351AA; margin-right: 0.5rem;"></i>
          Analyse en cours
        </h2>
        <p>L'IA génère votre résumé personnalisé</p>
        <div style="margin-top: 1.5rem; color: #666; font-size: 0.9rem; opacity: 0.8;">
          <i class="fas fa-hourglass-half" style="margin-right: 0.3rem;"></i>
          Cela peut prendre quelques secondes...
        </div>
      </div>
    `
    document.body.appendChild(loading)


    const modal = bootstrap.Modal.getInstance(document.getElementById('uploadModal'))
    if (modal) modal.hide()
  }
}
