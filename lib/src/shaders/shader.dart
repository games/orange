part of orange;




abstract class Shader {

  static final Shader simpleColorShader = new SimpleColorShader._internal();
  static final Shader phongShader = new PhongShader._internal();
  
  String name;
  String vertexSource;
  String fragmentSource;
  gl.Program program;
  
  compile() {
    if(program == null) {
      var ctx = _director.renderer.ctx;
      gl.Shader vertexShader = ctx.createShader(gl.VERTEX_SHADER);
      ctx.shaderSource(vertexShader, vertexSource);
      ctx.compileShader(vertexShader);
  
      gl.Shader fragmentShader = ctx.createShader(gl.FRAGMENT_SHADER);
      ctx.shaderSource(fragmentShader, fragmentSource);
      ctx.compileShader(fragmentShader);
      
      program = ctx.createProgram();
      ctx.attachShader(program, vertexShader);
      ctx.attachShader(program, fragmentShader);
      ctx.linkProgram(program);
      
      var linkedStatus = ctx.getProgramParameter(program, gl.LINK_STATUS);
      if(!linkedStatus) {
        print(ctx.getShaderInfoLog(vertexShader));
        print(ctx.getShaderInfoLog(fragmentShader));
        print(ctx.getProgramInfoLog(program));
      }
      
      _initAttributes();
      _initUniforms();
    }
  }
  
  _initAttributes();
  _initUniforms();
  
  use() {
    _director.renderer.ctx.useProgram(program);
  }
  
  setupLights(List<Light> lights){}
  setupAttributes(Mesh mesh);
  setupUniforms(Mesh mesh);
}


class SimpleColorShader extends Shader {
  int vertexPositionAttribute;
  int vertexNormalAttribute;
  gl.UniformLocation pMatrixUniform;
  gl.UniformLocation mvMatrixUniform;
  gl.UniformLocation uNormalMatrix;
  
  SimpleColorShader._internal() {
    name = "simpleColor";
    vertexSource = shader_normal_color_vertex_source;
    fragmentSource = shader_normal_color_fragment_source;
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
    pMatrixUniform = ctx.getUniformLocation(program, "uPMatrix");
    mvMatrixUniform = ctx.getUniformLocation(program, "uMVMatrix");
    uNormalMatrix = ctx.getUniformLocation(program, "uNormalMatrix");
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
    ctx.uniformMatrix4fv(pMatrixUniform, false, tmp);
    
    mesh.matrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(mvMatrixUniform, false, tmp);
    
    var normalMatrix = new Matrix4.zero();
    normalMatrix.copyInverse(mesh.matrix);
    normalMatrix.transpose();
    normalMatrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(uNormalMatrix, false, tmp);
  }
}













//
//class DefaultShader extends Shader {
//
//  int vertexPositionAttribute;
//  int vertexNormalAttribute;
//  int vertexTextureAttribute;
//  gl.UniformLocation pMatrixUniform;
//  gl.UniformLocation mvMatrixUniform;
//  gl.UniformLocation uNormalMatrix;
//  gl.UniformLocation samplerUniform;
//  
//  DefaultShader._internal() {
//    name = "default";
//    vertexSource = """
//        attribute vec3 aVertexPosition;
//        attribute vec2 aTextureCoord;
//        attribute highp vec3 aVertexNormal;
//
//        uniform mat4 uNormalMatrix;
//        uniform mat4 uMVMatrix;
//        uniform mat4 uPMatrix;
//
//        varying highp vec3 vLighting;
//        varying vec2 vTextureCoord;
//
//        void main(void) {
//        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
//
//        vTextureCoord = aTextureCoord;
//
//        //apply lighting effect
//        highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
//        highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
//        highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);
//
//        highp vec4 transformedNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
//        highp float directional = max(dot(transformedNormal.xyz, directionalVector), 0.0);
//        vLighting = ambientLight + (directionalLightColor * directional);
//        }
//        """;
//    fragmentSource = """
//        precision mediump float;
//
//        uniform sampler2D uSampler;
//
//        varying highp vec3 vLighting;
//
//        varying vec2 vTextureCoord;
//
//        void main(void) {
//        vec4 texelColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
//        gl_FragColor = vec4(texelColor.rgb * vLighting, 1.0);
//        }
//        """;
//  }
//  
//  _setupAttribs() {
//    var ctx = _director.renderer.ctx;
//
//    vertexPositionAttribute = ctx.getAttribLocation(program, "aVertexPosition");
//    ctx.enableVertexAttribArray(vertexPositionAttribute);
//    
//    vertexNormalAttribute = ctx.getAttribLocation(program, "aVertexNormal");
//    ctx.enableVertexAttribArray(vertexNormalAttribute);
//    
//    vertexTextureAttribute = ctx.getAttribLocation(program, "aTextureCoord");
//    ctx.enableVertexAttribArray(vertexTextureAttribute);
//    
//    pMatrixUniform = ctx.getUniformLocation(program, "uPMatrix");
//    mvMatrixUniform = ctx.getUniformLocation(program, "uMVMatrix");
//    uNormalMatrix = ctx.getUniformLocation(program, "uNormalMatrix");
//    samplerUniform = ctx.getUniformLocation(program, "uSampler");
//  }
//
//  prepare(Mesh mesh) {
//    // TODO implement this method
//  }
//}











