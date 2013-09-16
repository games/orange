part of orange;


class PhongShader extends Shader {
  final int MAX_LIGHTS = 4;

  int vertexPositionAttribute;
  int vertexNormalAttribute;
  gl.UniformLocation pMatrixUniform;
  gl.UniformLocation mvMatrixUniform;
  gl.UniformLocation uNormalMatrix;
  List<Map<String, gl.UniformLocation>> lightsUniform;
  
  PhongShader._internal() {
    name = "phongShader";
    vertexSource = 
    """
    attribute vec3 aVertexPosition;
    attribute highp vec3 aVertexNormal;
    
    uniform mat3 uNormalMatrix;
    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;
    
    varying vec3 vNormal;
    varying vec4 vPosition;
    
    void main(void) {
      vNormal = uNormalMatrix * aVertexNormal;
      vPosition = uMVMatrix * vec4(aVertexPosition, 1.0);
      gl_Position = uPMatrix * vPosition;
    }
    """;
    
    fragmentSource = 
        """
        precision mediump float;
        $shader_lights_include_source
        varying vec3 vNormal;
        varying vec4 vPosition;
        void main(void) {
          float specularIntensity = 1.0;
          float shininess = 1.0;
          vec4 tc = vec4(1.0, 0.0, 0.0, 1.0);
          vec3 l = computeLights(vPosition, vNormal, specularIntensity, shininess);
          gl_FragColor = vec4(tc.rgb * l, tc.a);
        }
        """;
    
//    vertexSource = shader_normal_color_vertex_source;
//    fragmentSource = shader_normal_color_fragment_source;
  }
  
  _initAttributes() {
    var ctx = _director.renderer.ctx;
    
    vertexPositionAttribute = ctx.getAttribLocation(program, "aVertexPosition");
    ctx.enableVertexAttribArray(vertexPositionAttribute);
    
    vertexNormalAttribute = ctx.getAttribLocation(program, "aVertexNormal");
    ctx.enableVertexAttribArray(vertexNormalAttribute);
    
    pMatrixUniform = ctx.getUniformLocation(program, "uPMatrix");
    mvMatrixUniform = ctx.getUniformLocation(program, "uMVMatrix");
    uNormalMatrix = ctx.getUniformLocation(program, "uNormalMatrix");
    
    lightsUniform = new List(MAX_LIGHTS);
    for(var i = 0; i < MAX_LIGHTS; i++) {
      var lightSource = new Map<String, gl.UniformLocation>();
      lightSource["type"] = ctx.getUniformLocation(program, "uLight$i.type");
      lightSource["direction"] = ctx.getUniformLocation(program, "uLight$i.direction");
      lightSource["position"] = ctx.getUniformLocation(program, "uLight$i.position");
      lightSource["color"] = ctx.getUniformLocation(program, "uLight$i.color");
      lightSource["intensity"] = ctx.getUniformLocation(program, "uLight$i.intensity");
      lightSource["angleFalloff"] = ctx.getUniformLocation(program, "uLight$i.angleFalloff");
      lightSource["angle"] = ctx.getUniformLocation(program, "uLight$i.angle");
      lightsUniform[i] = lightSource;
    }
    
//    var numUni = ctx.getProgramParameter(program, gl.ACTIVE_UNIFORMS);
//    for (var i = 0; i < numUni; i++) {
//        var acUni = ctx.getActiveUniform(program, i);
//        print(acUni);
//    }
  }

  _initUniforms() {
    // TODO implement this method
  }
  
  setupLights(List<Light> lights) {
//    var ctx = _director.renderer.ctx;
//    for(var i = 0; i < MAX_LIGHTS; i++) {
//      var lightSource = lightsUniform[i];
//      if(i < lights.length) {
//        ctx.uniform1i(lightSource["type"], lights[i].type);
//        ctx.uniform3fv(lightSource["direction"], lights[i].position);
//        ctx.uniform3fv(lightSource["color"], lights[i].color.rgb);
//        ctx.uniform3fv(lightSource["position"], lights[i].position);
//        ctx.uniform1f(lightSource["intensity"], lights[i].intensity);
//        ctx.uniform1f(lightSource["angleFalloff"], lights[i].angleFalloff);
//        ctx.uniform1f(lightSource["angle"], lights[i].angle);
//      }else{
//        ctx.uniform1i(lightSource["type"], Light.NONE);
//      }
//    }
  }
  
  setupAttributes(Mesh mesh) {
    var ctx = _director.renderer.ctx;
    ctx.bindBuffer(gl.ARRAY_BUFFER, mesh._geometry.vertexBuffer);
    ctx.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0);
    
//    ctx.bindBuffer(gl.ARRAY_BUFFER, mesh._geometry.normalBuffer);
//    ctx.vertexAttribPointer(vertexNormalAttribute, 3, gl.FLOAT, false, 0, 0);
    
    Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
    _director.scene.camera.projectionMatrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(pMatrixUniform, false, tmp);
    
    mesh.matrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(mvMatrixUniform, false, tmp);
    
    var normalMatrix = new Matrix4.zero();
    normalMatrix.copyInverse(mesh.matrix);
    normalMatrix.transpose();
    normalMatrix.copyIntoArray(tmp);
//    normalMatrix
    ctx.uniformMatrix4fv(uNormalMatrix, false, tmp);
  }

  setupUniforms(Mesh mesh) {
    // TODO implement this method
  }
}