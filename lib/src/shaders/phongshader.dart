part of orange;


final String _shader_light_structure2 = """
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

final String _shader_lights2 = """
uniform lightSource uLight0;
uniform lightSource uLight1;
uniform lightSource uLight2;
uniform lightSource uLight3;
vec3 computeLight(vec4 position, vec4 normal, lightSource ls) {
  if(ls.type == -1)
    return vec3(0.0, 0.0, 0.0);
  if(ls.type == 0) 
    return ls.color;
  float directional = max(dot(normalize(normal.xyz), normalize(ls.direction)), 0.0);
  return ls.color * directional;
}


vec3 phong2(vec4 position, vec4 normal, lightSource ls) {


  vec3 eyePosition = normalize(uCameraPosition);
  vec3 lightPosition = normalize(ls.position);
  vec3 P = normalize(position.xyz);
  vec3 N = normalize(normal.xyz);

  //ambient term
  vec3 ambient = ls.ambient;

  //diffuse term
  vec3 L = normalize(lightPosition - P);
  float diffuseLight = max(dot(N, L), 0.0);
  vec3 diffuse = ls.color * diffuseLight;

  //specular term
  float specularLight = 0.0;
  if(diffuseLight > 0.0) {
    vec3 V = normalize(eyePosition - P);
    vec3 H = normalize(reflect(lightPosition, N)); //normalize(L + V);
    specularLight = pow(max(dot(N, H), 0.0), ls.shininess);
  }
  vec3 specular = ls.color * specularLight;

  return ambient + diffuse + specular;
}


""";



final String _shader_phong_vertex_source = 
"""
attribute vec3 aVertexPosition;
attribute highp vec3 aVertexNormal;

uniform mat4 uProjectionMatrix;
uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uNormalMatrix;

varying vec3 vPosition;
varying vec3 vNormal;

void main(void) {

  vec4 vertPos4 = uViewMatrix * uModelMatrix * vec4(aVertexPosition, 1.0);

  gl_Position = uProjectionMatrix * vertPos4;

  vPosition = vec3(vertPos4) / vertPos4.w;
  vNormal = vec3(uNormalMatrix * vec4(aVertexNormal, 0.0));
}
""";

final String _shader_phong_fragment_source = 
"""
precision mediump float;

const vec3 lightPos = vec3(1.0,1.0,1.0);
const vec3 ambientColor = vec3(0.3, 0.0, 0.0);
const vec3 diffuseColor = vec3(0.5, 0.0, 0.0);
const vec3 specColor = vec3(1.0, 1.0, 1.0);
const int mode = 1;

uniform vec3 uMaterialAmbient;
uniform vec3 uMaterialDiffuse;
uniform vec3 uMaterialSpecular;
uniform vec3 uCameraPosition;

varying vec3 vPosition;
varying vec3 vNormal;

void main(void) {
    vec3 normal = normalize(vNormal);
    vec3 lightDir = normalize(lightPos - vPosition);
    vec3 reflectDir = reflect(-lightDir, normal);
    vec3 viewDir = normalize(-vPosition);

    float lambertian = max(dot(lightDir,normal), 0.0);
    float specular = 0.0;

    if(lambertian > 0.0) {
       float specAngle = max(dot(reflectDir, viewDir), 0.0);
       specular = pow(specAngle, 4.0);
    }
    gl_FragColor = vec4(ambientColor +
                      lambertian*diffuseColor +
                      specular*specColor, 1.0);

    // only ambient
    if(mode == 2) gl_FragColor = vec4(ambientColor, 1.0);
    // only diffuse
    if(mode == 3) gl_FragColor = vec4(lambertian*diffuseColor, 1.0);
    // only specular
    if(mode == 4) gl_FragColor = vec4(specular*specColor, 1.0);
}
""";



class PhongShader extends Shader {
  final int MAX_LIGHTS = 4;
  
  int vertexPositionAttribute;
  int vertexNormalAttribute;
  gl.UniformLocation projectionMatrixUniform;
  gl.UniformLocation modelMatrixUniform;
  gl.UniformLocation viewMatrixUniform;
  gl.UniformLocation normalMatrixUniform;
  gl.UniformLocation cameraPositionUniform;
  List<Map<String, gl.UniformLocation>> lightsUniform;
  
  PhongShader._internal() {
    name = "PhongShader";
    vertexSource = _shader_phong_vertex_source;
    fragmentSource = _shader_phong_fragment_source;
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
      lightSource["ambient"] = ctx.getUniformLocation(program, "uLight$i.ambient");
      lightSource["diffuse"] = ctx.getUniformLocation(program, "uLight$i.diffuse");
      lightSource["specular"] = ctx.getUniformLocation(program, "uLight$i.specular");
      lightSource["shininess"] = ctx.getUniformLocation(program, "uLight$i.shininess");
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
    
//    _director.scene.camera.matrix.copyIntoArray(tmp);
//    ctx.uniformMatrix4fv(viewMatrixUniform, false, tmp);
    
    _director.scene.camera.copyViewMatrixIntoArray(tmp);
    ctx.uniformMatrix4fv(viewMatrixUniform, false, tmp);
    
    ctx.uniform3fv(cameraPositionUniform, vector3ToFloat32List(_director.scene.camera.position));
    
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
//        if(light.intensity != null)
//          ctx.uniform1f(lightSource["intensity"], light.intensity);
//        if(light.angleFalloff != null)
//          ctx.uniform1f(lightSource["angleFalloff"], light.angleFalloff);
//        if(light.angle != null)
//          ctx.uniform1f(lightSource["angle"], light.angle);
        if(light.ambient != null)
          ctx.uniform3fv(lightSource["ambient"], vector3ToFloat32List(light.ambient));
        if(light.diffuse != null)
          ctx.uniform3fv(lightSource["diffuse"], vector3ToFloat32List(light.diffuse));
        if(light.specular != null)
          ctx.uniform3fv(lightSource["specular"], vector3ToFloat32List(light.specular));
        if(light.shininess != null)
          ctx.uniform1f(lightSource["shininess"], light.shininess);
      }else{
        ctx.uniform1i(lightSource["type"], Light.NONE);
      }
    }
  }
  
  vector3ToFloat32List(Vector3 vec) {
    return new Float32List.fromList([vec.x, vec.y, vec.z]);
  }
}