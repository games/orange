part of orange;


final String _shader_light_structure = """
struct lightSource {
  int type;

  vec3 direction;     // used by directional and spotlight (global direction of the transfom)
  vec3 position;      // used by hemisphere, point, spotlight (it's the global position of the transform)

  vec3 color;         // used by d/p/s and hemisphere
  float intensity;    // used by spherical harmonics & d/p/s
  float angleFalloff; // used by hemisphere and spotlight (TODO: change to falloff)
  float angle;        // used by spotlight
  // float attenuation; // used by point, spot, hemisphere (TODO: implement)
};
""";

final String _shader_lights = """
uniform lightSource uLight0;
vec3 computeLight(vec4 position, vec4 normal, float specularIntensity, float shininess, lightSource ls) {
  if(ls.type == 0) {
    return ls.color;
  }
  float directional = max(dot(normal.xyz, ls.direction), 0.0);
  return ls.color * directional;
}
""";



final String _shader_normal_color_vertex_source = 
"""
attribute vec3 aVertexPosition;
attribute highp vec3 aVertexNormal;

uniform mat4 uProjectionMatrix;
uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uNormalMatrix;
$_shader_light_structure
$_shader_lights

varying vec3 vLighting;

void main(void) {
  vec4 vPosition = uProjectionMatrix * uViewMatrix * uModelMatrix * vec4(aVertexPosition, 1.0);
  gl_Position = vPosition;
  //apply lighting effect
  highp vec3 ambientLight = vec3(0.6, 0.6, 0.6);
  highp vec3 directionalLightColor = vec3(0.5, 0.5, 0.75);
  highp vec3 directionalVector = vec3(0.85, 0.8, 0.75);

  vec4 transformedNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
  vLighting = computeLight(vPosition, transformedNormal, 0.0, 0.0, uLight0);
}
""";

final String _shader_normal_color_fragment_source = 
"""
precision mediump float;
varying vec3 vLighting;

void main(void) {
  gl_FragColor = vec4(vec3(1.0, 0.0, 0.0) * vLighting, 1.0);
}
""";



class SimpleShader extends Shader {
  final int MAX_LIGHTS = 4;
  
  int vertexPositionAttribute;
  int vertexNormalAttribute;
  gl.UniformLocation projectionMatrixUniform;
  gl.UniformLocation modelMatrixUniform;
  gl.UniformLocation viewMatrixUniform;
  gl.UniformLocation normalMatrixUniform;
  List<Map<String, gl.UniformLocation>> lightsUniform;
  
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
  
  setupLights(List<Light> lights) {
    final MAX_LIGHTS = 1;
    var ctx = _director.renderer.ctx;
    for(var i = 0; i < MAX_LIGHTS; i++) {
      var lightSource = lightsUniform[i];
      if(i < lights.length) {
        ctx.uniform1i(lightSource["type"], lights[i].type);
        ctx.uniform3fv(lightSource["direction"], vector3ToFloat32List(lights[i].position));
        ctx.uniform3fv(lightSource["color"], vector3ToFloat32List(lights[i].color.rgb));
        ctx.uniform3fv(lightSource["position"], vector3ToFloat32List(lights[i].position));
        ctx.uniform1f(lightSource["intensity"], lights[i].intensity);
        ctx.uniform1f(lightSource["angleFalloff"], lights[i].angleFalloff);
        ctx.uniform1f(lightSource["angle"], lights[i].angle);
      }else{
        ctx.uniform1i(lightSource["type"], Light.NONE);
      }
    }
    

    print([vector3ToFloat32List(lights[0].color.rgb)]);
  }
  
  vector3ToFloat32List(Vector3 vec) {
    return new Float32List.fromList([vec.x, vec.y, vec.z]);
  }
}