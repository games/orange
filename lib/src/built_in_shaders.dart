part of orange;




const String modelVS = """
precision highp float;
attribute vec3 position;
attribute vec2 texture;
attribute vec3 normal;
uniform mat4 viewMat;
uniform mat4 modelMat;
uniform mat4 projectionMat;
uniform vec3 lightPos;
varying vec2 vTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vEyeDir;
// A manual rotation matrix transpose to get the normal matrix
mat3 getNormalMat(mat4 mat) {
    return mat3(mat[0][0], mat[1][0], mat[2][0], mat[0][1], mat[1][1], mat[2][1], mat[0][2], mat[1][2], mat[2][2]);
}

void main(void) {
  mat4 modelViewMat = viewMat * modelMat;
  mat3 normalMat = getNormalMat(modelViewMat);
  vec4 vPosition = modelViewMat * vec4(position, 1.0);
  gl_Position = projectionMat * vPosition;
  vTexture = texture;
  vNormal = normalize(normal * normalMat);
  vLightDir = normalize(lightPos-vPosition.xyz);
  vEyeDir = normalize(-vPosition.xyz);
}
""";

const String modelFS = """
precision highp float;
uniform sampler2D diffuse;
varying vec2 vTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vEyeDir;
void main(void) {
 float shininess = 8.0;
 vec3 specularColor = vec3(1.0, 1.0, 1.0);
 vec3 lightColor = vec3(1.0, 1.0, 1.0);
 vec3 ambientLight = vec3(0.15, 0.15, 0.15);
 vec4 color = texture2D(diffuse, vTexture);
 vec3 normal = normalize(vNormal);
 vec3 lightDir = normalize(vLightDir);
 vec3 eyeDir = normalize(vEyeDir);
 vec3 reflectDir = reflect(-lightDir, normal);
 float specularLevel = color.a;
 float specularFactor = pow(clamp(dot(reflectDir, eyeDir), 0.0, 1.0), shininess) * specularLevel;
 float lightFactor = max(dot(lightDir, normal), 0.0);
 vec3 lightValue = ambientLight + (lightColor * lightFactor) + (specularColor * specularFactor);
 gl_FragColor = vec4(color.rgb * lightValue, 1.0);
}
""";


const String lightmapVS = """
precision highp float;
attribute vec3 position;
attribute vec2 texture;
attribute vec2 texture2;
uniform mat4 viewMat;
uniform mat4 modelMat;
uniform mat4 projectionMat;
uniform vec2 lightmapScale;
uniform vec2 lightmapOffset;
varying vec2 vTexCoord;
varying vec2 vLightCoord;
void main(void) {
 mat4 modelViewMat = viewMat * modelMat;
 vec4 vPosition = modelViewMat * vec4(position, 1.0);
 gl_Position = projectionMat * vPosition;
 vTexCoord = texture;
 vLightCoord = texture2 * lightmapScale + lightmapOffset;
}
""";


const String lightmapFS = """
precision highp float;
uniform sampler2D diffuse;
uniform sampler2D lightmap;
varying vec2 vTexCoord;
varying vec2 vLightCoord;
void main(void) {
 vec4 color = texture2D(diffuse, vTexCoord);
 vec4 lightValue = texture2D(lightmap, vLightCoord);
 float brightness = 9.0;
 gl_FragColor = vec4(color.rgb * lightValue.rgb * (lightValue.a * brightness), 1.0);
}
""";

const int MAX_BONES_PER_MESH = 50;

const String skinnedModelVS = """
precision highp float;
attribute vec3 position;
attribute vec2 texture;
attribute vec3 normal;
attribute vec3 weights;
attribute vec3 bones;

uniform mat4 viewMat;
uniform mat4 modelMat;
uniform mat4 projectionMat;
uniform mat4 boneMat[$MAX_BONES_PER_MESH];

uniform vec3 lightPos;

varying vec2 vTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vEyeDir;

mat4 accumulateSkinMat() {
   mat4 result = weights.x * boneMat[int(bones.x)];
   result = result + weights.y * boneMat[int(bones.y)];
   result = result + weights.z * boneMat[int(bones.z)];
   return result;
}

// A "manual" rotation matrix transpose to get the normal matrix
mat3 getNormalMat(mat4 mat) {
   return mat3(mat[0][0], mat[1][0], mat[2][0], mat[0][1], mat[1][1], mat[2][1], mat[0][2], mat[1][2], mat[2][2]);
}

void main(void) {
   mat4 modelViewMat = viewMat * modelMat;
   mat4 skinMat = modelViewMat * accumulateSkinMat();
   mat3 normalMat = getNormalMat(skinMat);

   vec4 vPosition = skinMat * vec4(position, 1.0);
   gl_Position = projectionMat * vPosition;

   vTexture = texture;
   vNormal = normalize(normal * normalMat);
   vLightDir = normalize(lightPos-vPosition.xyz);
   vEyeDir = normalize(-vPosition.xyz);
}
""";


const String skinnedModelFS = """
precision highp float;
uniform sampler2D diffuse;

varying vec2 vTexture;
varying vec3 vNormal;
varying vec3 vLightDir;
varying vec3 vEyeDir;

void main(void) {
 float shininess = 8.0;
 vec3 specularColor = vec3(1.0, 1.0, 1.0);
 vec3 lightColor = vec3(1.0, 1.0, 1.0);
 vec3 ambientLight = vec3(0.15, 0.15, 0.15);

 vec4 color = texture2D(diffuse, vTexture);
 vec3 normal = normalize(vNormal);
 vec3 lightDir = normalize(vLightDir);
 vec3 eyeDir = normalize(vEyeDir);
 vec3 reflectDir = reflect(-lightDir, normal);

 float specularLevel = color.a;
 float specularFactor = pow(clamp(dot(reflectDir, eyeDir), 0.0, 1.0), shininess) * specularLevel;
 float lightFactor = max(dot(lightDir, normal), 0.0);
 vec3 lightValue = ambientLight + (lightColor * lightFactor) + (specularColor * specularFactor);
 gl_FragColor = vec4(color.rgb * lightValue, 1.0);
}
""";












