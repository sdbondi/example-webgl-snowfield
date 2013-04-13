namespace 'SF', (exports) ->
	class exports.SnowflakeExample
		constructor: (@element, @options) ->
			@cameraRadius = 200
			@particleSystemHeight = @options.height / 5

			@parameters = 
				color: 0xFFFFFF
				height: @particleSystemHeight

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
					color: { type: 'c', value: new THREE.Color(@parameters.color) }
					height: { type: 'f', value: @particleSystemHeight }
					elapsedTime: { type: 'f', value: 0 }
				vertexShader: @options.vertexShader, 
				fragmentShader: @options.fragmentShader
			
			@generateParticles(options.numParticles)

			@particleSystem = new THREE.ParticleSystem(@sysGeometry, @sysMaterial)
			@particleSystem.position.y = - @particleSystemHeight / 2

			@clock = new THREE.Clock()
			@scene.add(@particleSystem)

			@initializeDatGui()

		initializeDatGui: =>
			@controls = new dat.GUI()
			@controls.addColor(@parameters, 'color').onChange =>
				@sysMaterial.uniforms.color.value.set(@parameters.color)

			@controls.add(@parameters, 'height').onChange =>
				@sysMaterial.uniforms.height.value = @parameters.height

		render: (t) =>
			window.requestAnimationFrame(@render)

			# delta = @clock.getDelta()
			elapsedTime = @clock.getElapsedTime()
			t = elapsedTime * 0.5

			@particleSystem.material.uniforms.elapsedTime.value = elapsedTime * 10

			@camera.position.set( @cameraRadius * Math.sin( t ), 0, @cameraRadius * Math.cos( t ) );
			@camera.lookAt( @cameraTarget );

			@renderer.clear();
			@renderer.render( @scene, @camera );

	# Private
		generateParticles: (numParticles = 100) =>
			width  = @options.width / 5
			height = @particleSystemHeight
			depth  = @options.depth / 5

			for i in [0..numParticles - 1]
				vertex = new THREE.Vector3(
					rand(width), 
					Math.random() * height, 
					rand(depth)
				)
				@sysGeometry.vertices.push(vertex)

		rand = (v) -> v * (Math.random() - 0.5)
