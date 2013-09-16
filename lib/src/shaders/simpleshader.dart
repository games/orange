part of orange;



final String _shader_normal_color_vertex_source = 
"""
attribute vec3 aVertexPosition;
attribute highp vec3 aVertexNormal;

uniform mat4 uProjectionMatrix;
uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uNormalMatrix;

varying highp vec3 vLighting;

void main(void) {
  gl_Position = uProjectionMatrix * uViewMatrix * uModelMatrix * vec4(aVertexPosition, 1.0);
  //apply lighting effect
  highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
  highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
  highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);

  highp vec4 transformedNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
  highp float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
  vLighting = ambientLight + (directionalLightColor * directional);
}
""";

final String _shader_normal_color_fragment_source = 
"""
precision mediump float;
varying highp vec3 vLighting;

void main(void) {
  gl_FragColor = vec4(vec3(1.0, 0.0, 0.0) * vLighting, 1.0);
}
""";



class SimpleShader extends Shader {
  int vertexPositionAttribute;
  int vertexNormalAttribute;
  gl.UniformLocation projectionMatrixUniform;
  gl.UniformLocation modelMatrixUniform;
  gl.UniformLocation viewMatrixUniform;
  gl.UniformLocation normalMatrixUniform;
  
  SimpleShader._internal() {
    name = "simpleShader";
    vertexSource = _shader_normal_color_vertex_source;
    fragmentSource = _shader_normal_color_fragment_source;
  }
  
  _initAttributes() {
    var ctx = _director.renderer.ctx;
    vertexPositionAttribute = ctx.getAttribLocation(program, "aVertexPosition");
    ctx.enableVertexAttribArray(vertexPositionAttribute);
    
    vertexNormalAttribute = ctx.getAttribLocation(program, "aVertexNormal");
    ctx.enableVertexAttribArray(vertexNormalAttribute);
  }

  _initUniforms() {
    var ctx = _director.renderer.ctx;
    projectionMatrixUniform = ctx.getUniformLocation(program, "uProjectionMatrix");
    modelMatrixUniform = ctx.getUniformLocation(program, "uModelMatrix");
    viewMatrixUniform = ctx.getUniformLocation(program, "uViewMatrix");
    normalMatrixUniform = ctx.getUniformLocation(program, "uNormalMatrix");
  }
  
  setupAttributes(Mesh mesh) {
    var ctx = _director.renderer.ctx;
    
    ctx.bindBuffer(gl.ARRAY_BUFFER, mesh._geometry.vertexBuffer);
    ctx.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0);
    
    ctx.bindBuffer(gl.ARRAY_BUFFER, mesh._geometry.normalBuffer);
    ctx.vertexAttribPointer(vertexNormalAttribute, 3, gl.FLOAT, false, 0, 0);
  }

  setupUniforms(Mesh mesh) {
    var ctx = _director.renderer.ctx;
    
    Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
    
    _director.scene.camera.projectionMatrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(projectionMatrixUniform, false, tmp);
    
//    _director.scene.camera.matrix.copyIntoArray(tmp);
//    ctx.uniformMatrix4fv(viewMatrixUniform, false, tmp);
    
    _director.scene.camera.copyViewMatrixIntoArray(tmp);
    ctx.uniformMatrix4fv(viewMatrixUniform, false, tmp);
    
    mesh.matrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(modelMatrixUniform, false, tmp);
    
    var normalMatrix = new Matrix4.zero();
    normalMatrix.copyInverse(mesh.matrix);
    normalMatrix.transpose();
    normalMatrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(normalMatrixUniform, false, tmp);
  }
}