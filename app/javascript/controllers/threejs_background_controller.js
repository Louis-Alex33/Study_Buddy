import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.initThreeJS()
  }

  disconnect() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId)
    }
    if (this.renderer) {
      this.renderer.dispose()
    }
  }

  initThreeJS() {
    // Import Three.js from CDN
    if (typeof THREE === 'undefined') {
      const script = document.createElement('script')
      script.src = 'https://cdn.jsdelivr.net/npm/three@0.159.0/build/three.min.js'
      script.onload = () => this.setupScene()
      document.head.appendChild(script)
    } else {
      this.setupScene()
    }
  }

  setupScene() {
    const canvas = this.element

    // Scene setup with dark professional background
    this.scene = new THREE.Scene()
    this.scene.fog = new THREE.Fog(0x0a0e1a, 1, 1000)

    // Camera
    this.camera = new THREE.PerspectiveCamera(
      75,
      window.innerWidth / window.innerHeight,
      0.1,
      1000
    )
    this.camera.position.z = 50

    // Renderer
    this.renderer = new THREE.WebGLRenderer({
      canvas: canvas,
      alpha: true,
      antialias: true
    })
    this.renderer.setSize(window.innerWidth, window.innerHeight)
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

    // Particles - more subtle
    this.createParticles()

    // Geometric shapes - elegant and minimal
    this.createGeometricShapes()

    // Professional lighting
    const ambientLight = new THREE.AmbientLight(0x1e3a5f, 0.4)
    this.scene.add(ambientLight)

    // Accent lights - golden and blue
    const pointLight1 = new THREE.PointLight(0xf59e0b, 1.5, 150)
    pointLight1.position.set(20, 20, 20)
    this.scene.add(pointLight1)

    const pointLight2 = new THREE.PointLight(0x3b82f6, 1.5, 150)
    pointLight2.position.set(-20, -20, 20)
    this.scene.add(pointLight2)

    const pointLight3 = new THREE.PointLight(0x8b5cf6, 1, 100)
    pointLight3.position.set(0, 0, -30)
    this.scene.add(pointLight3)

    // Handle resize
    window.addEventListener('resize', () => this.onWindowResize())

    // Mouse tracking for parallax
    this.mouseX = 0
    this.mouseY = 0
    document.addEventListener('mousemove', (e) => {
      this.mouseX = (e.clientX / window.innerWidth) * 2 - 1
      this.mouseY = -(e.clientY / window.innerHeight) * 2 + 1
    })

    // Animate
    this.animate()
  }

  createParticles() {
    const particlesGeometry = new THREE.BufferGeometry()
    const particlesCount = 1500
    const posArray = new Float32Array(particlesCount * 3)

    for (let i = 0; i < particlesCount * 3; i++) {
      posArray[i] = (Math.random() - 0.5) * 150
    }

    particlesGeometry.setAttribute('position', new THREE.BufferAttribute(posArray, 3))

    // Create multiple particle systems with different colors
    const colors = [
      { color: 0x3b82f6, size: 0.1, opacity: 0.4 },  // Blue
      { color: 0xf59e0b, size: 0.15, opacity: 0.3 }, // Amber
      { color: 0x8b5cf6, size: 0.08, opacity: 0.5 }  // Purple
    ]

    this.particleSystems = []

    colors.forEach((config, index) => {
      const material = new THREE.PointsMaterial({
        size: config.size,
        color: config.color,
        transparent: true,
        opacity: config.opacity,
        blending: THREE.AdditiveBlending,
        depthWrite: false
      })

      const particles = new THREE.Points(particlesGeometry.clone(), material)
      particles.rotation.x = Math.random() * Math.PI
      particles.rotation.y = Math.random() * Math.PI
      this.scene.add(particles)
      this.particleSystems.push(particles)
    })
  }

  createGeometricShapes() {
    this.shapes = []

    // Elegant wireframe sphere
    const sphereGeometry = new THREE.SphereGeometry(4, 32, 32)
    const sphereMaterial = new THREE.MeshStandardMaterial({
      color: 0x3b82f6,
      wireframe: true,
      transparent: true,
      opacity: 0.15,
      emissive: 0x3b82f6,
      emissiveIntensity: 0.2
    })
    const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial)
    sphere.position.set(-25, 10, -20)
    this.scene.add(sphere)
    this.shapes.push({ mesh: sphere, speed: 0.2 })

    // Minimalist torus
    const torusGeometry = new THREE.TorusGeometry(5, 1, 16, 100)
    const torusMaterial = new THREE.MeshStandardMaterial({
      color: 0xf59e0b,
      wireframe: true,
      transparent: true,
      opacity: 0.2,
      emissive: 0xf59e0b,
      emissiveIntensity: 0.3
    })
    const torus = new THREE.Mesh(torusGeometry, torusMaterial)
    torus.position.set(25, -10, -30)
    this.scene.add(torus)
    this.shapes.push({ mesh: torus, speed: 0.15 })

    // Abstract dodecahedron
    const dodecaGeometry = new THREE.DodecahedronGeometry(3, 0)
    const dodecaMaterial = new THREE.MeshStandardMaterial({
      color: 0x8b5cf6,
      wireframe: true,
      transparent: true,
      opacity: 0.18,
      emissive: 0x8b5cf6,
      emissiveIntensity: 0.25
    })
    const dodeca = new THREE.Mesh(dodecaGeometry, dodecaMaterial)
    dodeca.position.set(0, 15, -40)
    this.scene.add(dodeca)
    this.shapes.push({ mesh: dodeca, speed: 0.25 })

    // Subtle ring
    const ringGeometry = new THREE.TorusGeometry(6, 0.3, 8, 64)
    const ringMaterial = new THREE.MeshStandardMaterial({
      color: 0x3b82f6,
      transparent: true,
      opacity: 0.1,
      emissive: 0x3b82f6,
      emissiveIntensity: 0.15
    })
    const ring = new THREE.Mesh(ringGeometry, ringMaterial)
    ring.position.set(-15, -15, -25)
    this.scene.add(ring)
    this.shapes.push({ mesh: ring, speed: 0.1 })
  }

  animate() {
    this.animationId = requestAnimationFrame(() => this.animate())

    const time = Date.now() * 0.0003

    // Subtle particle rotation
    this.particleSystems.forEach((system, index) => {
      system.rotation.y = time * (0.1 + index * 0.05)
      system.rotation.x = time * 0.05
    })

    // Elegant shape animations
    this.shapes.forEach((shape, index) => {
      const { mesh, speed } = shape
      mesh.rotation.x = time * speed
      mesh.rotation.y = time * speed * 1.5
      mesh.position.y += Math.sin(time * 2 + index) * 0.008
    })

    // Subtle camera parallax
    this.camera.position.x += (this.mouseX * 2 - this.camera.position.x) * 0.02
    this.camera.position.y += (this.mouseY * 2 - this.camera.position.y) * 0.02
    this.camera.lookAt(this.scene.position)

    this.renderer.render(this.scene, this.camera)
  }

  onWindowResize() {
    this.camera.aspect = window.innerWidth / window.innerHeight
    this.camera.updateProjectionMatrix()
    this.renderer.setSize(window.innerWidth, window.innerHeight)
  }
}
