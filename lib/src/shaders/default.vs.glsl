precision highp float;
attribute vec3 a_position;
uniform mat4 u_worldViewProjectionMatrix;
void main(void) {
	gl_Position = u_worldViewProjectionMatrix * vec4(a_position, 1.0);
}
