import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pointsValue"]

  connect() {
    console.log("Points cheat controller connected!")
  }

  cheat(event) {
    event.preventDefault()
    console.log("Cheat activated!")

    // Send POST request to add points
    fetch('/cheat_points', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ points: 50 })
    })
    .then(response => {
      console.log("Response status:", response.status)
      return response.json()
    })
    .then(data => {
      console.log("Response data:", data)
      if (data.success) {
        // Update the points display with animation
        this.pointsValueTarget.textContent = data.new_points

        // Add a fun animation effect
        const pointsElement = this.element
        pointsElement.classList.add('cheat-activated')

        // Show a temporary notification
        this.showCheatNotification(data.points_added)

        // Remove animation class after it completes
        setTimeout(() => {
          pointsElement.classList.remove('cheat-activated')
        }, 1000)

        // Reload page after 1.5 seconds to update league if needed
        setTimeout(() => {
          window.location.reload()
        }, 1500)
      } else {
        console.error("Cheat failed: success is false")
      }
    })
    .catch(error => {
      console.error('Cheat failed:', error)
    })
  }

  showCheatNotification(points) {
    // Create screen flash
    const flash = document.createElement('div')
    flash.className = 'cheat-flash'
    document.body.appendChild(flash)
    setTimeout(() => flash.remove(), 800)

    // Create particles
    this.createParticles()

    // Create notification element
    const notification = document.createElement('div')
    notification.className = 'cheat-notification'
    notification.innerHTML = `
      <i class="fas fa-star"></i>
      +${points} points!
      <span class="cheat-emoji">🎉</span>
    `

    // Add to body
    document.body.appendChild(notification)

    // Trigger animation
    setTimeout(() => {
      notification.classList.add('show')
    }, 10)

    // Remove after animation
    setTimeout(() => {
      notification.classList.remove('show')
      setTimeout(() => {
        notification.remove()
      }, 500)
    }, 2000)
  }

  createParticles() {
    const particles = ['⭐', '✨', '💫', '🌟', '⚡', '💥', '🎊', '🎉']
    const colors = ['#FFD700', '#FF8C00', '#FF6347', '#FFA500']

    // Create 30 particles
    for (let i = 0; i < 30; i++) {
      setTimeout(() => {
        const particle = document.createElement('div')
        particle.className = 'cheat-particle'
        particle.textContent = particles[Math.floor(Math.random() * particles.length)]
        particle.style.color = colors[Math.floor(Math.random() * colors.length)]
        particle.style.left = `${Math.random() * 100}vw`
        particle.style.top = `${Math.random() * 100}vh`
        particle.style.filter = `drop-shadow(0 0 10px ${colors[Math.floor(Math.random() * colors.length)]})`

        document.body.appendChild(particle)

        // Remove after animation
        setTimeout(() => particle.remove(), 2000)
      }, i * 50) // Stagger particle creation
    }
  }
}
