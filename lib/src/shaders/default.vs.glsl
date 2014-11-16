precision highp float;
attribute vec3 aPosition;
attribute vec2 aUV;
attribute vec3 aNormal;

uniform mat4 uViewMat;
uniform mat4 uModelMat;
uniform mat4 uProjectionMat;
uniform mat3 uNormalMat;

varying vec4 vPosition;
varying vec2 vDiffuseUV;
varying vec3 vLighting;

void main(void) {
   mat4 modelViewMat = uViewMat * uModelMat;

  vPosition = modelViewMat * vec4(aPosition, 1.0);
  gl_Position = uProjectionMat * vPosition;

  vec3 normal = normalize(uNormalMat * aNormal);

  highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
  highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
  highp vec3 directionalVector = vec3(-2.0, 2.0, 2.0);
  highp float directional = max(dot(normal, directionalVector), 0.0);
  vec3 lighting = ambientLight + (directionalLightColor * directional);

  vDiffuseUV = aUV;
  vLighting = lighting;
}