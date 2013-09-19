part of orange;


final String _shader_light_structure = """
struct lightSource {
  int type;

  vec3 direction;     // used by directional and spotlight (global direction of the transfom)
  vec3 position;      // used by hemisphere, point, spotlight (it's the global position of the transform)

  vec3 color;    

  vec3 ambient;       // Ambient light intensity
  vec3 diffuse;       // Diffuse light intensity
  vec3 specular;      // Specular light intensity
  float shininess;
};
""";

final String _shader_lights = """
uniform lightSource uLight0;
uniform lightSource uLight1;
uniform lightSource uLight2;
uniform lightSource uLight3;
vec3 computeLight(vec4 position, vec4 normal, float specularIntensity, float shininess, lightSource ls) {
  if(ls.type == -1)
    return vec3(0.0, 0.0, 0.0);
  if(ls.type == 0) 
    return ls.color;
  float directional = max(dot(normal.xyz, ls.direction), 0.0);
  return ls.color * directional;
}

vec3 phong(vec4 position, vec4 normal, lightSource ls) {
  vec3 eye = -vec3(position.xyz);
  vec3 l = normalize(ls.direction);
  vec3 n = normalize(normal);
  //lambert's cosine law
  float lambertTerm = dot(n, -l);
  //ambient term
  vec3 ia = ls.ambient * uMaterialAmbient;
  //diffuse term
  vec3 id = vec3(0.0, 0.0, 0.0);
  //specular term
  vec3 is = vec3(0.0, 0.0, 0.0);
  if(lambertTerm > 0.0){
    id = ls.diffuse * uMaterialDiffuse * lambertTerm;
    vec3 e = normalize(eye);
    vec3 r = reflect(l, n);
    float specular = pow(max(dot(r, e), 0.0), ls.shininess);
    is = ls.specular * uMaterialSpecular * specular;
  }
  vec3 finalColor = ia + id + is;
  return finalColor;
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

uniform vec3 uMaterialAmbient;
uniform vec3 uMaterialDiffuse;
uniform vec4 uMaterialSpecular

varying vec4 vPosition;
varying vec4 vNormal;

void main(void) {
  vPosition = uViewMatrix * uModelMatrix * vec4(aVertexPosition, 1.0);
  gl_Position = uProjectionMatrix * vPosition;
  vNormal = uNormalMatrix * vec4(aVertexNormal, 1.0);
}
""";

final String _shader_normal_color_fragment_source = 
"""
precision mediump float;

varying vec4 vPosition;
varying vec4 vNormal;

$_shader_light_structure
$_shader_lights

void main(void) {
  //vec3 lighting = computeLight(vPosition, vNormal, 0.0, 0.0, uLight0) + 
  //                computeLight(vPosition, vNormal, 0.0, 0.0, uLight1) + 
  //                computeLight(vPosition, vNormal, 0.0, 0.0, uLight2) + 
  //                computeLight(vPosition, vNormal, 0.0, 0.0, uLight3);
  vec3 lighting = computeLight(vPosition, vNormal, 0.0, 0.0, uLight0) + 
                  phong(vPosition, vNormal, uLight1);

  gl_FragColor = vec4(vec3(1.0, 0.0, 0.0) * lighting, 1.0);
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
    var ctx = _director.renderer.ctx;
    for(var i = 0; i < MAX_LIGHTS; i++) {
      var lightSource = lightsUniform[i];
      if(i < lights.length) {
        var light = lights[i];
        ctx.uniform1i(lightSource["type"], light.type);
        ctx.uniform3fv(lightSource["direction"], vector3ToFloat32List(light.position));
        ctx.uniform3fv(lightSource["color"], vector3ToFloat32List(light.color.rgb));
        ctx.uniform3fv(lightSource["position"], vector3ToFloat32List(light.position));
        if(light.intensity != null)
          ctx.uniform1f(lightSource["intensity"], light.intensity);
        if(light.angleFalloff != null)
          ctx.uniform1f(lightSource["angleFalloff"], light.angleFalloff);
        if(light.angle != null)
          ctx.uniform1f(lightSource["angle"], light.angle);
      }else{
        ctx.uniform1i(lightSource["type"], Light.NONE);
      }
    }
  }
  
  vector3ToFloat32List(Vector3 vec) {
    return new Float32List.fromList([vec.x, vec.y, vec.z]);
  }
}