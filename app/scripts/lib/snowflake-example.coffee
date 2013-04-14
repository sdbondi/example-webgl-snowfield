namespace 'SF', (exports) ->
	class exports.SnowflakeExample
		constructor: (@element, @options) ->
			@cameraRadius = 50
			@cameraX = 0
			@cameraY = 0
			@cameraZ = @cameraRadius
			@particleSystemHeight = @options.height / 2

			@parameters = 
				opacity: 1.0
				scale: 5.0
				size: 100
				snowDriftRadiusX: 2
				snowDriftRadiusY: 2
				color: 0xFFFFFF
				height: @particleSystemHeight
				speedH: 2
				speedV: 2

			@initialize(@options)

		initialize: (options) =>
			# Create renderer
			@renderer = new THREE.WebGLRenderer(canvas: @element)
			@renderer.setSize(options.width, options.height)
			@renderer.setClearColor(new THREE.Color(0x000000), 1.0)

			@scene = new THREE.Scene()

			@camera = new THREE.PerspectiveCamera(45, options.width / options.height, 1, 10000)
			@cameraTarget = new THREE.Vector3(0, 0, 0)

			@sysGeometry = new THREE.Geometry()
			@sysMaterial = new THREE.ShaderMaterial
				uniforms: 
					texture: { type: 't', value: THREE.ImageUtils.loadTexture(@options.snowflakeTextureUrl) }
					opacity: { type: 'f', value: @parameters.opacity }
					scale: { type: 'f', value: @parameters.scale }
					size: { type: 'f', value: @parameters.size }
					radiusX: { type: 'f', value: @parameters.snowDriftRadiusX }
					radiusY: { type: 'f', value: @parameters.snowDriftRadiusY }
					color: { type: 'c', value: new THREE.Color(@parameters.color) }
					height: { type: 'f', value: @parameters.height }
					elapsedTime: { type: 'f', value: 0 }
					speedH: { type: 'f', value: @parameters.speedH }
					speedV: { type: 'f', value: @parameters.speedV }
				vertexShader: @options.vertexShader
				fragmentShader: @options.fragmentShader
				blending: THREE.AdditiveBlending
				transparent: true
				depthTest: false
			
			@generateParticles(options.numParticles)

			@particleSystem = new THREE.ParticleSystem(@sysGeometry, @sysMaterial)
			@particleSystem.position.y = - @particleSystemHeight / 2

			@camera.lookAt( @cameraTarget )

			@clock = new THREE.Clock()
			@scene.add(@particleSystem)

			@initializeDatGui()

			@attachUIEvents()

		initializeDatGui: =>
			@controls = new dat.GUI()
			@controls.addColor(@parameters, 'color').onChange =>
				@sysMaterial.uniforms.color.value.set(@parameters.color)

			@controls.add(@parameters, 'height').min(0).max(@particleSystemHeight * 2.0).onChange =>
				@sysMaterial.uniforms.height.value = @parameters.height

			@controls.add(@parameters, 'snowDriftRadiusX').min(0).max(10).onChange =>
				@sysMaterial.uniforms.radiusX.value = @parameters.snowDriftRadiusX

			@controls.add(@parameters, 'snowDriftRadiusY').min(0).max(10).onChange =>
				@sysMaterial.uniforms.radiusY.value = @parameters.snowDriftRadiusY

			@controls.add(@parameters, 'scale').min(1).max(10).onChange =>
				@sysMaterial.uniforms.scale.value = @parameters.scale

			@controls.add(@parameters, 'size').min(1).max(300).onChange =>
				@sysMaterial.uniforms.size.value = @parameters.size

			@controls.add(@parameters, 'opacity').min(0).max(1).step(0.1).onChange =>
				@sysMaterial.uniforms.opacity.value = @parameters.opacity

			@controls.add(@parameters, 'speedH').min(0.1).max(3).step(0.1).onChange =>
				@sysMaterial.uniforms.speedH.value = @parameters.speedH

			@controls.add(@parameters, 'speedV').min(0.1).max(3).step(0.1).onChange =>
				@sysMaterial.uniforms.speedV.value = @parameters.speedV

		attachUIEvents: =>
			@element.addEventListener 'mousemove', (e) =>
				mouseX = e.clientX
				mouseY = e.clientY
				halfWidth = @options.width >> 1
				halfHeight = @options.height >> 1

				@cameraX = @cameraRadius * (mouseX - halfHeight) / halfHeight
				@cameraY = @cameraRadius * (mouseY - halfWidth) / halfWidth

			@element.addEventListener 'mousewheel', (e) => 
				e.preventDefault()
				@cameraZ += -e.wheelDelta * 0.5 unless @cameraZ <= 0 && e.wheelDelta > 0

		render: (t) =>
			window.requestAnimationFrame(@render)

			# delta = @clock.getDelta()
			elapsedTime = @clock.getElapsedTime()

			@particleSystem.material.uniforms.elapsedTime.value = elapsedTime * 10

			# Camera rotation
			# t = elapsedTime * 0.5
			# @camera.position.set( @cameraRadius * Math.sin( t ), 0, @cameraRadius * Math.cos( t ) )
			@camera.position.set( @cameraX, @cameraY, @cameraZ )
			@camera.lookAt( @cameraTarget )

			@renderer.clear();
			@renderer.render( @scene, @camera );

		generateParticles: (numParticles = 100) =>
			width  = @options.width / 2
			height = @particleSystemHeight
			depth  = @options.depth / 2

			for i in [0..numParticles - 1]
				vertex = new THREE.Vector3(
					rand(width), 
					Math.random() * height, 
					rand(depth)
				)
				@sysGeometry.vertices.push(vertex)

	# Private
		rand = (v) -> v * (Math.random() - 0.5)
