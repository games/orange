precision highp float;

varying vec4 vPosition;
//varying vec2 vTexcoords;
varying vec3 vNormal;
varying vec3 vLighting;

void main(void) {
  vec3 color = vec3(0.4, 0.4, 0.4);
  gl_FragColor = vec4(color * vLighting, 1.0);
}