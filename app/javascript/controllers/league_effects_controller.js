import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("League effects controller connected!")
    const league = this.element.dataset.league
    console.log("Current league:", league)

    // Start spawning particles
    this.spawnParticles(league)

    // Continuously spawn particles
    this.particleInterval = setInterval(() => {
      this.spawnParticles(league)
    }, 3000) // Spawn new batch every 3 seconds
  }

  disconnect() {
    if (this.particleInterval) {
      clearInterval(this.particleInterval)
    }
  }

  spawnParticles(league) {
    // Particle configurations by rank - color based particles
    const particleConfigs = {
      'iron': { colors: ['#4A4A4A', '#6B6B6B', '#808080'], count: 3, size: 8 },
      'bronze': { colors: ['#CD7F32', '#B87333', '#A0522D'], count: 4, size: 10 },
      'silver': { colors: ['#C0C0C0', '#D3D3D3', '#E8E8E8'], count: 5, size: 12 },
      'gold': { colors: ['#FFD700', '#FFC700', '#FFB700'], count: 6, size: 14 },
      'platinum': { colors: ['#00CED1', '#20B2AA', '#48D1CC'], count: 7, size: 16 },
      'emerald': { colors: ['#50C878', '#3CB371', '#2E8B57'], count: 8, size: 18 },
      'diamond': { colors: ['#B9F2FF', '#87CEEB', '#00BFFF'], count: 9, size: 20 },
      'master': { colors: ['#9B30FF', '#8A2BE2', '#9370DB'], count: 12, size: 22 },
      'grandmaster': { colors: ['#FF4500', '#FF6347', '#FF7F50'], count: 15, size: 24 },
      'challenger': { colors: ['#F4C430', '#FFD700', '#FFA500', '#FF8C00'], count: 20, size: 28 }
    }

    const config = particleConfigs[league] || particleConfigs['iron']

    for (let i = 0; i < config.count; i++) {
      setTimeout(() => {
        this.createParticle(config.colors, config.size, league)
      }, i * 150) // Stagger particle creation
    }
  }

  createParticle(colors, size, league) {
    const particle = document.createElement('div')
    particle.className = 'league-particle'

    // Random color from the league's palette
    const color = colors[Math.floor(Math.random() * colors.length)]

    // Random elongated blob shape (not circular)
    const width = size * (0.5 + Math.random() * 1.5) // 50% to 200% of base size
    const height = size * (0.3 + Math.random() * 0.7) // 30% to 100% of base size
    const borderRadius = `${30 + Math.random() * 40}% ${40 + Math.random() * 50}% ${30 + Math.random() * 40}% ${40 + Math.random() * 50}%`

    // Style the particle as a fluid blob
    particle.style.width = `${width}px`
    particle.style.height = `${height}px`
    particle.style.backgroundColor = color
    particle.style.borderRadius = borderRadius
    particle.style.boxShadow = `0 0 ${size * 2}px ${color}, 0 0 ${size * 3}px ${color}`
    particle.style.filter = 'blur(2px)'
    particle.style.opacity = '0.6'

    // Random starting position
    particle.style.left = `${Math.random() * 100}vw`
    particle.style.top = `${Math.random() * 100}vh`

    // Random animation delay and duration for variety
    particle.style.animationDelay = `${Math.random() * 3}s`
    particle.style.animationDuration = `${8 + Math.random() * 8}s` // 8-16s for fluid movement

    // Random rotation
    particle.style.transform = `rotate(${Math.random() * 360}deg)`

    this.element.appendChild(particle)

    // Remove particle after animation completes (varies by rank)
    const durations = {
      'iron': 8000,
      'bronze': 9000,
      'silver': 10000,
      'gold': 10000,
      'platinum': 11000,
      'emerald': 11000,
      'diamond': 12000,
      'master': 12000,
      'grandmaster': 13000,
      'challenger': 14000
    }

    setTimeout(() => {
      particle.remove()
    }, durations[league] || 8000)
  }
}
