precision highp float;

uniform sampler2D uDiffuseTexture;

varying vec4 vPosition;
varying vec2 vDiffuseUV;
varying vec3 vNormal;
varying vec3 vLighting;

void main(void) {
  vec3 color = texture2D(uDiffuseTexture, vDiffuseUV).rgb;

  gl_FragColor = vec4(color * vLighting, 1.0);
}