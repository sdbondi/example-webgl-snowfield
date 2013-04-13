'use strict'

template = """
<div>
	<canvas></canvas>

	<script type="x-shader/x-vertex">
	uniform float height;
	uniform float elapsedTime;

	void main() {
		vec3 pos = position;
		pos.y = mod(pos.y - elapsedTime, height);
		gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
	}
	</script>

	<script type="x-shader/x-fragment">
	uniform vec3 color;

	void main() {
		gl_FragColor = vec4(color, 1.0);
	}
	</script>
</div>
"""
angular.module('webglExamples')
	.directive 'snowflakecanvas', ->
		restrict: 'E'
		scope: {
			width: '='
			height: '='
			numParticles: '='
			depth: '='
		}
		replace: true
		template: template
		link: (scope, element, attrs, controller) ->
			example = new SF.SnowflakeExample element.find('canvas')[0],
				vertexShader: element.find('[type="x-shader/x-vertex"]')[0].textContent,
				fragmentShader: element.find('[type="x-shader/x-fragment"]')[0].textContent,
				width: scope.width, 
				height: scope.height,
				numParticles: scope.numParticles || 100,
				depth: scope.depth || scope.width

			example.render(window.requestAnimationFrame)
