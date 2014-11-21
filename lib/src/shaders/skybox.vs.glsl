// reflectionCubeSampler
// reflection infos: coordinatesMode, reflection level, 1.0
// reflectionMatrix
// 
// 

#ifdef GL_ES
precision highp float;
#endif

attribute vec3 position;

uniform mat4 world;
uniform mat4 viewProjection;

varying vec3 vPosition;

void main(void) {
	vPosition = position;
	gl_Position = viewProjection * world * vec4(position, 1.0);
}

