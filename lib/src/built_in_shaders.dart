part of orange;







const int MAX_JOINTS_PER_MESH = 60;

const String skinnedModelVS = """
precision highp float;
attribute vec3 aPosition;
attribute vec2 aTexture;
attribute vec3 aNormal;
attribute vec4 aJoints;
attribute vec4 aWeights;

uniform mat4 uViewMat;
uniform mat4 uModelMat;
uniform mat4 uProjectionMat;
uniform mat4 uJointMat[$MAX_JOINTS_PER_MESH];

uniform vec3 uLightPos;

varying vec4 vPosition;
varying vec2 vTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vEyeDir;

mat4 accumulateSkinMat() {
   mat4 result = aWeights.x * uJointMat[int(aJoints.x)];
   result = result + aWeights.y * uJointMat[int(aJoints.y)];
   result = result + aWeights.z * uJointMat[int(aJoints.z)];
   result = result + aWeights.w * uJointMat[int(aJoints.w)];
   return result;
}

// A "manual" rotation matrix transpose to get the normal matrix
mat3 getNormalMat(mat4 mat) {
   return mat3(mat[0][0], mat[1][0], mat[2][0], mat[0][1], mat[1][1], mat[2][1], mat[0][2], mat[1][2], mat[2][2]);
}

void main(void) {
   mat4 modelViewMat = uViewMat * uModelMat;
   mat4 skinMat = modelViewMat * accumulateSkinMat();
   mat3 normalMat = getNormalMat(skinMat);

   vPosition = skinMat * vec4(aPosition, 1.0);
   gl_Position = uProjectionMat * vPosition;

   vTexture = aTexture;
   vNormal = normalize(aNormal * normalMat);
   vLightDir = normalize(uLightPos - vPosition.xyz);
   vEyeDir = normalize(-vPosition.xyz);
}
""";


const String skinnedModelFS = """
precision highp float;
uniform sampler2D diffuse;
// material
uniform vec4 specularColor;
uniform vec3 diffuseColor;
uniform vec3 ambientColor;
uniform vec3 emissiveColor;

$_shader_light_structure
$_shader_lights

varying vec4 vPosition;
varying vec2 vTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vEyeDir;

void main(void) {
 float shininess = specularColor.w;

 vec4 color = texture2D(diffuse, vTexture);
 vec3 normal = normalize(vNormal);
 vec3 lightDir = normalize(vLightDir);
 vec3 eyeDir = normalize(vEyeDir);
 vec3 reflectDir = reflect(-lightDir, normal);

 vec3 lighting = computeLight(vPosition.xyz, vNormal, light0, shininess) + 
                 computeLight(vPosition.xyz, vNormal, light1, shininess) + 
                 computeLight(vPosition.xyz, vNormal, light2, shininess) + 
                 computeLight(vPosition.xyz, vNormal, light3, shininess);

 float specularLevel = color.a;
 float specularFactor = pow(clamp(dot(reflectDir, eyeDir), 0.0, 1.0), shininess) * specularLevel;
 float lightFactor = max(dot(lightDir, normal), 0.0);
 vec3 lightValue = emissiveColor + 
                   ambientColor + 
                   (diffuseColor * lighting * lightFactor) + 
                   (specularColor.xyz * lighting * specularFactor);
 gl_FragColor = vec4(color.rgb * lightValue, 1.0);
}
""";



const String _shader_light_structure = """
struct lightSource {
  int type;
  vec3 direction;
  vec3 position;
  vec3 color;
  float intensity;
  float spotExponent;
  float spotCosCutoff;
  float constantAttenuation;
  float linearAttenuation;
  float quadraticAttenuation;
};
""";

const String _shader_lights = """
uniform lightSource light0;
uniform lightSource light1;
uniform lightSource light2;
uniform lightSource light3;
uniform vec3 cameraPosition;

vec3 phong(vec3 position, vec3 normal, lightSource ls, float shininess) {
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
    vec3 viewDirection = normalize(cameraPosition - position);
    vec3 H = normalize(viewDirection + towardLight);
    float specAngle = max(dot(normal, H), 0.0);
    specular = ls.color * pow(specAngle, shininess);
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

vec3 computeLight(vec3 position, vec3 normal, lightSource ls, float shininess) {
  if(ls.type < 0 || ls.type > 5)
    return vec3(0.0, 0.0, 0.0);
  if(ls.type == 0)
    return ls.color * ls.intensity;
  return phong(position, normal, ls, shininess);
}

""";




















