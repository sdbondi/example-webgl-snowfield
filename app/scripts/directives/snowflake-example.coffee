'use strict'

template = """
<div>
	<canvas></canvas>

	<script type="x-shader/x-vertex">
	uniform float speedH;
	uniform float speedV;
	uniform float radiusX;
	uniform float radiusY;
	uniform float height;
	uniform float scale;
	uniform float size;
	uniform float elapsedTime;

	void main() {
		vec3 pos = position;
		pos.x += cos( ( elapsedTime + position.z ) * 0.25 * speedH ) * radiusX;
		pos.y = mod( pos.y - elapsedTime, height );
		pos.z += sin( ( elapsedTime + position.x ) * 0.25 * speedV ) * radiusY;

		vec4 mvPosition = modelViewMatrix * vec4( pos, 1.0 );

		gl_PointSize = size * ( scale / length( mvPosition.xyz ) );
		gl_Position = projectionMatrix * mvPosition;
	}
	</script>

	<script type="x-shader/x-fragment">
	uniform vec3 color;
	uniform sampler2D texture;
	uniform float opacity;

	void main() {
		vec4 texColor = texture2D(texture, gl_PointCoord);
		gl_FragColor = texColor * vec4(color, opacity);
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
				width: scope.width || window.innerWidth, 
				height: scope.height || window.innerHeight,
				numParticles: scope.numParticles || 100,
				depth: scope.depth || scope.width
				snowflakeTextureUrl: '/images/snowflake.png'

			example.render(window.requestAnimationFrame)
