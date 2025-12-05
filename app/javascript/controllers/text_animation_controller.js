import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (typeof anime !== 'undefined') {
      this.splitText()
      this.updateColors()
      this.animateText()
      this.observeThemeChanges()
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  splitText() {
    const text = this.element.textContent
    this.element.innerHTML = ''

    text.split('').forEach(char => {
      const span = document.createElement('span')
      span.textContent = char
      span.style.display = 'inline-block'
      span.className = 'hero-highlight-char'
      this.element.appendChild(span)
    })
  }

  animateText() {
    const spans = this.element.querySelectorAll('span')

    anime.timeline({loop: false})
      .add({
        targets: spans,
        translateY: ['-2.75rem', 0],
        rotate: ['-1turn', 0],
        opacity: [0, 1],
        easing: 'easeOutExpo',
        duration: 1400,
        delay: anime.stagger(50)
      })
  }

  updateColors() {
    const spans = this.element.querySelectorAll('span')
    const isDarkMode = document.body.getAttribute('data-theme') === 'dark'

    spans.forEach(span => {
      if (isDarkMode) {
        span.style.color = '#4a90e2'
        span.style.background = 'transparent'
        span.style.webkitTextFillColor = '#4a90e2'
        span.style.webkitBackgroundClip = 'unset'
        span.style.backgroundClip = 'unset'
        span.style.filter = 'none'
      } else {
        span.style.background = 'linear-gradient(135deg, #FFD700 0%, #FFA500 100%)'
        span.style.webkitBackgroundClip = 'text'
        span.style.backgroundClip = 'text'
        span.style.webkitTextFillColor = 'transparent'
        span.style.filter = 'drop-shadow(0 2px 4px rgba(0, 0, 0, 0.3))'
        span.style.color = ''
      }
    })
  }

  observeThemeChanges() {
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'attributes' && mutation.attributeName === 'data-theme') {
          this.updateColors()
        }
      })
    })

    this.observer.observe(document.body, {
      attributes: true,
      attributeFilter: ['data-theme']
    })
  }
}
