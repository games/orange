#ifdef GL_ES
precision highp float;
#endif


uniform samplerCube cubeSampler;
varying vec3 vPositionUVW;

void main(void) {
    vec3 color = textureCube(cubeSampler, vPositionUVW).rgb;
    gl_FragColor = vec4(color, 1.0);
}




















