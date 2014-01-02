part of orange;


Pass passForTextureMaterial = _makePassForTextureMaterial();
Technique techniqueForTextureMaterial = _makeTechniqueForTextureMaterial();

Technique _makeTechniqueForTextureMaterial() {
  var technique = new Technique();
  technique.parameters = {
     "modelViewMatrix": {"semantic": "MODELVIEW", "type": 35676},
     "projectionMatrix": {"semantic": "PROJECTION", "type": 35676},
     "position": {"semantic": "POSITION", "type": 35665},
     "normal": {"semantic": "NORMAL", "type": 35665},
     "normalMatrix": {"semantic": "MODELVIEWINVERSETRANSPOSE", "type": 35675},
     "texcoord0": {"semantic": "TEXCOORD_0", "type": 35664},
     "diffuse": {"type": 35678}
  };
  technique.pass = "defaultPass";
  technique.passes = {"defaultPass": passForTextureMaterial};
  return technique;
}


Pass _makePassForTextureMaterial() {
  var pass = new Pass();
  pass.program = _makeProgramForTextureMaterial();
  pass.details = {};
  pass.instanceProgram = {
     "attributes": {
      "a_position": "position",
      "a_normal": "normal",
      "a_texcoord0": "texcoord0"
     },
     "program": "debugProgram",
     "uniforms": {
       "u_modelViewMatrix": "modelViewMatrix",
       "u_projectionMatrix": "projectionMatrix",
       "u_normalMatrix": "normalMatrix",
       "u_texture_sampler": "diffuse"
     }
  };
  pass.states = {
     "blendEnable": 0,
     "cullFaceEnable": 1,
     "depthMask": 1,
     "depthTestEnable": 1
  };
  return pass;
}


Program _makeProgramForTextureMaterial() {
  var program = new Program();
  program.vertexShader = new Shader();
  program.vertexShader.source = 
"""
  precision highp float;
  attribute vec3 a_position;
  attribute vec3 a_normal;
  attribute vec2 a_texcoord0;
  uniform mat4 u_modelViewMatrix;
  uniform mat4 u_projectionMatrix;
  uniform mat3 u_normalMatrix;
  
  varying highp vec3 v_lighting;
  varying vec2 v_texcoord0;

  void main(void) { 
    gl_Position = u_projectionMatrix * u_modelViewMatrix * vec4(a_position,1.0); 

    highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
    highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
    highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);
    highp vec3 transformedNormal = u_normalMatrix * a_normal;
    highp float directional = max(dot(transformedNormal, directionalVector), 0.0);
    v_lighting = ambientLight + (directionalLightColor * directional);
    v_texcoord0 = a_texcoord0;
  }
""";
  
  program.fragmentShader = new Shader();
  program.fragmentShader.source = 
"""
  precision highp float;
  uniform vec3 u_color;
  uniform sampler2D u_texture_sampler;
  varying highp vec3 v_lighting;
  varying vec2 v_texcoord0;
  void main(void) {
    vec4 color = texture2D(u_texture_sampler, v_texcoord0);
    gl_FragColor = vec4(color.xyz * v_lighting, 1.0); 
  }
""";
  
  program.attributes = ["", "", ""];
  return program;
}