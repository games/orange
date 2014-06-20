part of orange;




const SHADER_COLOR_VS = """
precision mediump float;

// Attributes
attribute vec3 position;

// Uniforms
uniform mat4 worldViewProjection;

void main(void) {
  gl_Position = worldViewProjection * vec4(position, 1.0);
}
""";

const SHADER_COLOR_FS = """
precision mediump float;

uniform vec3 color;

void main(void) {
  gl_FragColor = vec4(color, 1.);
}
""";