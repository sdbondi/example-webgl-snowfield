'use strict'
app = angular.module('webglExamples')

class SnowflakeExample
	constructor: (@element, @options) ->
		@cameraRadius = 200

		# Create renderer
		@renderer = new THREE.WebGLRenderer(canvas: element)
		@renderer.setSize(options.width, options.height)
		@renderer.setClearColor(new THREE.Color(0x000000), 1.0)

		@scene = new THREE.Scene()

		@camera = new THREE.PerspectiveCamera(45, options.width / options.height, 1, 10000)
		@cameraTarget = new THREE.Vector3(0, 0, 0)

		@sysGeometry = new THREE.Geometry()
		@sysMaterial = new THREE.ParticleBasicMaterial(color: 0xFFFFFF)

		@generateParticles(options.numParticles)

		@particleSystem = new THREE.ParticleSystem(@sysGeometry, @sysMaterial)
		@particleSystem.position.y = - (options.height / 5) / 2

		@clock = new THREE.Clock()
		@scene.add(@particleSystem)

	updateParticleSystem: (delta) =>
		geometry = @particleSystem.geometry
		vertices = geometry.vertices

		speedY = delta * 10

		for v in vertices
			if v.y > 0			
				v.y -= speedY * Math.random()
			else
				v.y = @options.height / 5

		geometry.verticesNeedUpdate = true

	render: (t) =>
		window.requestAnimationFrame(@render)

		delta = @clock.getDelta()
		t = @clock.getElapsedTime() * 0.5

		@updateParticleSystem(delta)

		@camera.position.set( @cameraRadius * Math.sin( t ), 0, @cameraRadius * Math.cos( t ) );
		@camera.lookAt( @cameraTarget );

		@renderer.clear();
		@renderer.render( @scene, @camera );

# Private
	generateParticles: (numParticles = 100) =>
		width  = @options.width / 5
		height = @options.height / 5
		depth  = @options.depth / 5

		for i in [0..numParticles - 1]
			vertex = new THREE.Vector3(
				rand(width), 
				Math.random() * height, 
				rand(depth)
			)
			@sysGeometry.vertices.push(vertex)

	rand = (v) -> v * (Math.random() - 0.5)

app.directive 'snowflakecanvas', ->
	restrict: 'E'
	scope: {
		width: '='
		height: '='
		numParticles: '='
		depth: '='
	}
	replace: true
	templateUrl: 'views/example_snowflake.html'
	link: (scope, element, attrs, controller) ->

		example = new SnowflakeExample element[0], 
			width: scope.width, 
			height: scope.height,
			numParticles: scope.numParticles || 100,
			depth: scope.depth || scope.width

		example.render(window.requestAnimationFrame)

app.controller 'MainCtrl', ['$scope', ($scope) -> ]