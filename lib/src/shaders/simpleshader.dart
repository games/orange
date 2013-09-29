part of orange;


final String _shader_light_structure = """
struct lightSource {
  int type;

  vec3 direction;     // used by directional and spotlight (global direction of the transfom)
  vec3 position;      // used by hemisphere, point, spotlight (it's the global position of the transform)
  vec3 color;
  float intensity;
  float spotExponent;
  float spotCosCutoff;
  float constantAttenuation;
  float linearAttenuation;
  float quadraticAttenuation;
};
""";

final String _shader_lights = """
uniform lightSource uLight0;
uniform lightSource uLight1;
uniform lightSource uLight2;
uniform lightSource uLight3;

vec3 phong(vec3 position, vec3 normal, lightSource ls) {
  vec3 P = normalize(position);
  vec3 lightPosition = ls.position;
  vec3 towardLight = lightPosition - position;
  vec3 lightDirection;
  // point light
  if(ls.type == 1){
    lightDirection = -ls.direction;
  } else {
    lightDirection = normalize(towardLight);
  }

  //diffuse term
  float diffuseAngle = max(dot(normal, lightDirection), 0.0);
  vec3 diffuse = ls.color * diffuseAngle;

  //specular term
  vec3 specular = vec3(0.0, 0.0, 0.0);
  if(diffuseAngle > 0.0){
    vec3 viewDirection = normalize(uCameraPosition - position);
    vec3 H = normalize(viewDirection + towardLight);
    float specAngle = max(dot(normal, H), 0.0);
    specular = ls.color * pow(specAngle, uShininess);
  }
  float attenuation = 0.0;
  float dist = length(towardLight);
  if(ls.type == 2) {
    attenuation = 1.0 / (ls.constantAttenuation + ls.linearAttenuation * dist + ls.quadraticAttenuation * dist * dist);
  } else if(ls.type == 3) {
    float spotEffect = dot(-ls.direction, lightDirection);
    if(spotEffect > ls.spotCosCutoff){
      spotEffect = pow(spotEffect, ls.spotExponent);
      attenuation = spotEffect / (ls.constantAttenuation + ls.linearAttenuation * dist + ls.quadraticAttenuation * dist * dist);
    }
  } else {
    attenuation = 1.0;
  }

  return diffuse * ls.intensity * attenuation  + specular * attenuation;
}

vec3 computeLight(vec3 position, vec3 normal, lightSource ls) {
  if(ls.type < 0 || ls.type > 5)
    return vec3(0.0, 0.0, 0.0);
  if(ls.type == 0)
    return ls.color * ls.intensity;
  return phong(position, normal, ls);
}

""";



final String _shader_normal_color_vertex_source = 
"""
precision mediump float;

attribute vec3 aVertexPosition;
attribute highp vec3 aVertexNormal;

uniform mat4 uProjectionMatrix;
uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uNormalMatrix;

varying vec3 vPosition;
varying vec3 vNormal;

void main(void) {
  vec4 pos = uModelMatrix * vec4(aVertexPosition, 1.0);
  gl_Position = uProjectionMatrix * uViewMatrix * pos;
  vPosition = pos.xyz;
  vNormal = normalize((uNormalMatrix * vec4(aVertexNormal, 0.0)).xyz);
}
""";

final String _shader_normal_color_fragment_source = 
"""
precision mediump float;

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform vec3 uMaterialAmbient;
uniform vec3 uMaterialDiffuse;
uniform vec3 uMaterialSpecular;
uniform vec3 uCameraPosition;
uniform vec3 uColor;
uniform float uShininess;

varying vec3 vPosition;
varying vec3 vNormal;

$_shader_light_structure
$_shader_lights

void main(void) {
  vec3 lighting = computeLight(vPosition, vNormal, uLight0) + 
                  computeLight(vPosition, vNormal, uLight1) + 
                  computeLight(vPosition, vNormal, uLight2) + 
                  computeLight(vPosition, vNormal, uLight3);
  gl_FragColor = vec4(lighting * uColor, 1.0);
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
  gl.UniformLocation cameraPositionUniform;
  gl.UniformLocation colorUniform;
  gl.UniformLocation shininessUniform;
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
    cameraPositionUniform = ctx.getUniformLocation(program, "uCameraPosition");
    colorUniform = ctx.getUniformLocation(program, "uColor");
    shininessUniform = ctx.getUniformLocation(program, "uShininess");
    
    lightsUniform = new List(MAX_LIGHTS);
    for(var i = 0; i < MAX_LIGHTS; i++) {
      var lightSource = new Map<String, gl.UniformLocation>();
      lightSource["type"] = ctx.getUniformLocation(program, "uLight$i.type");
      lightSource["direction"] = ctx.getUniformLocation(program, "uLight$i.direction");
      lightSource["position"] = ctx.getUniformLocation(program, "uLight$i.position");
      lightSource["color"] = ctx.getUniformLocation(program, "uLight$i.color");
      lightSource["intensity"] = ctx.getUniformLocation(program, "uLight$i.intensity");
      lightSource["spotExponent"] = ctx.getUniformLocation(program, "uLight$i.spotExponent");
      lightSource["spotCosCutoff"] = ctx.getUniformLocation(program, "uLight$i.spotCosCutoff");
      lightSource["constantAttenuation"] = ctx.getUniformLocation(program, "uLight$i.constantAttenuation");
      lightSource["linearAttenuation"] = ctx.getUniformLocation(program, "uLight$i.linearAttenuation");
      lightSource["quadraticAttenuation"] = ctx.getUniformLocation(program, "uLight$i.quadraticAttenuation");
      lightsUniform[i] = lightSource;
    }
  }
  
  setupAttributes(Mesh mesh) {
    var ctx = _director.renderer.ctx;
    
    if(mesh._geometry != null) {
      ctx.bindBuffer(gl.ARRAY_BUFFER, mesh._geometry.vertexBuffer);
      ctx.vertexAttribPointer(vertexPositionAttribute, 3, gl.FLOAT, false, 0, 0);
      
      ctx.bindBuffer(gl.ARRAY_BUFFER, mesh._geometry.normalBuffer);
      ctx.vertexAttribPointer(vertexNormalAttribute, 3, gl.FLOAT, false, 0, 0);
    }
  }

  setupUniforms(Mesh mesh) {
    var ctx = _director.renderer.ctx;
    
    Float32List tmp = new Float32List.fromList(new List.filled(16, 0.0));
    
    _director.scene.camera.projectionMatrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(projectionMatrixUniform, false, tmp);
    
    _director.scene.camera.copyViewMatrixIntoArray(tmp);
    ctx.uniformMatrix4fv(viewMatrixUniform, false, tmp);
    
    var cp = _director.scene.camera.matrix * _director.scene.camera.position;
    cp = _director.scene.camera.position;
    ctx.uniform3fv(cameraPositionUniform, vector3ToFloat32List(cp));
    
    mesh.matrix.copyIntoArray(tmp);
    ctx.uniformMatrix4fv(modelMatrixUniform, false, tmp);
    
    ctx.uniform3fv(colorUniform, vector3ToFloat32List(mesh.material.color.rgb));
    ctx.uniform1f(shininessUniform, mesh.material.shininess);
    
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
        ctx.uniform3fv(lightSource["direction"], vector3ToFloat32List(light.direction));
        ctx.uniform3fv(lightSource["color"], vector3ToFloat32List(light.color.rgb));
        ctx.uniform3fv(lightSource["position"], vector3ToFloat32List(light.position));
        ctx.uniform1f(lightSource["intensity"], light.intensity);
        ctx.uniform1f(lightSource["constantAttenuation"], light.constantAttenuation);
        ctx.uniform1f(lightSource["linearAttenuation"], light.linearAttenuation);
        ctx.uniform1f(lightSource["quadraticAttenuation"], light.quadraticAttenuation);
        if(light.spotExponent != null)
          ctx.uniform1f(lightSource["spotExponent"], light.spotExponent);
        if(light.spotCutoff != null)
          ctx.uniform1f(lightSource["spotCosCutoff"], light.spotCosCutoff);
      }else{
        ctx.uniform1i(lightSource["type"], Light.NONE);
      }
    }
  }
  
  vector3ToFloat32List(Vector3 vec) {
    return new Float32List.fromList([vec.x, vec.y, vec.z]);
  }
}