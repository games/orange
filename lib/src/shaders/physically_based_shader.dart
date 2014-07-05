part of orange;



const String SHADER_PHYSICALLY_BASED_VS = """
precision mediump float;

attribute vec3 position;
attribute vec3 normal;
attribute vec3 tangent;

#ifdef UV1
attribute vec2 uv;
#endif
#ifdef UV2
attribute vec2 uv2;
#endif

#ifdef BONES
attribute vec4 matricesIndices;
attribute vec4 matricesWeights;
#endif

#ifdef DIFFUSE
varying vec2 vDiffuseUV;
uniform mat4 diffuseMatrix;
uniform vec2 vDiffuseInfos;
#endif

#ifdef BUMP
varying vec2 vBumpUV;
uniform vec2 vBumpInfos;
uniform mat4 bumpMatrix;
#endif

#ifdef BONES
uniform mat4 mBones[BonesPerMesh];
#endif



uniform mat4 world;
uniform mat4 view;
uniform mat4 viewProjection;
uniform mat4 worldViewProjection;
uniform vec3 vEyePosition;

varying vec3 vWorldPosition;
varying vec3 vNormal;
varying vec3 vTangent;

void main(void) {
  vec4 wp = world * vec4(position, 1.0);
  vWorldPosition = wp.xyz; 
  vNormal = normalize(vec3(world * vec4(normal, 0.0)));

  #ifdef DIFFUSE
  #ifdef UV1
  vDiffuseUV = vec2(diffuseMatrix * vec4(uv, 1.0, 0.0));
  #endif
  #ifdef UV2
  vDiffuseUV = vec2(diffuseMatrix * vec4(uv2, 1.0, 0.0));
  #endif
  #endif
 
  gl_Position = viewProjection * wp;
}
""";



const String SHADER_PHYSICALLY_BASED_FS = """
precision mediump float;
precision mediump int;

#define PI 3.1415926535897932384626433832795
#define PI_OVER_TWO 1.5707963267948966
#define PI_OVER_FOUR 0.7853981633974483
#extension GL_OES_standard_derivatives : enable

uniform vec4 vDiffuseColor;
uniform vec3 vEyePosition;

uniform sampler2D diffuseSampler;
uniform sampler2D bumpSampler;
uniform float uAlbedo;
uniform float uRoughess;
uniform float uReflectivity;

varying vec3 vWorldPosition;
varying vec3 vNormal;
varying vec3 vTangent;

#ifdef DIFFUSE
varying vec2 vDiffuseUV;
uniform vec2 vDiffuseInfos;
#endif

float saturate(float d) {
  return clamp(d, 0.0, 1.0);
}

float G1V(float dotNV, float k) {
  return 1.0/(dotNV*(1.0-k)+k);
}

vec2 LightingFuncGGX_FV(float dotLH, float roughness) {
  float alpha = roughness*roughness;

  // F
  float F_a, F_b;
  float dotLH5 = pow(1.0-dotLH,5.0);
  F_a = 1.0;
  F_b = dotLH5;

  // V
  float vis;
  float k = alpha/2.0;
  float k2 = k*k;
  float invK2 = 1.0-k2;
  vis = inversesqrt(dotLH*dotLH*invK2 + k2);
  return vec2(F_a*vis,F_b*vis);
}

float LightingFuncGGX_D(float dotNH, float roughness) {
  float alpha = roughness*roughness;
  float alphaSqr = alpha*alpha;
  float denom = dotNH * dotNH *(alphaSqr-1.0) + 1.0;
  float D = alphaSqr/(PI * denom * denom);
  return D;
}

float LightingFuncGGX(vec3 N, vec3 V, vec3 L, float roughness, float F0) {
  vec3 H = normalize(V+L);

  float dotNL = saturate(dot(N,L));
  float dotLH = saturate(dot(L,H));
  float dotNH = saturate(dot(N,H));

  float D = LightingFuncGGX_D(dotNH,roughness);
  vec2 FV_helper = LightingFuncGGX_FV(dotLH,roughness);
  float FV = F0*FV_helper.x + (1.0-F0)*FV_helper.y;
  float specular = dotNL * D * FV;
  return specular;
}

mat3 cotangent_frame(vec3 normal, vec3 p, vec2 uv) {
  // get edge vectors of the pixel triangle
  vec3 dp1 = dFdx(p);
  vec3 dp2 = dFdy(p);
  vec2 duv1 = dFdx(uv);
  vec2 duv2 = dFdy(uv);

  // solve the linear system
  vec3 dp2perp = cross(dp2, normal);
  vec3 dp1perp = cross(normal, dp1);
  vec3 tangent = dp2perp * duv1.x + dp1perp * duv2.x;
  vec3 binormal = dp2perp * duv1.y + dp1perp * duv2.y;

  // construct a scale-invariant frame 
  float invmax = inversesqrt(max(dot(tangent, tangent), dot(binormal, binormal)));
  return mat3(tangent * invmax, binormal * invmax, normal);
}

vec3 perturbNormal(vec3 viewDir) {
  vec3 map = texture2D(bumpSampler, vDiffuseUV).xyz;
  map = map * 255. / 127. - 128. / 127.;
  mat3 TBN = cotangent_frame(vNormal, -viewDir, vDiffuseUV);
  return normalize(TBN * map);
}

void main(void) {
  vec3 diffuseColor = vDiffuseColor.rgb;
  vec4 baseColor = vec4(1.0, 1.0, 1.0, 1.0);
  #ifdef DIFFUSE
  baseColor = texture2D(diffuseSampler, vDiffuseUV);
  baseColor.rgb *= vDiffuseInfos.y;
  #endif
  float alpha = vDiffuseColor.a * baseColor.a;
  vec3 color = uAlbedo * diffuseColor * baseColor.xyz;

  vec3 light_colour = vec3(1.0, 1.0, 1.0);
  vec3 light_direction = normalize(vec3(1.0, 1.0, 1.0));

  float specular_power = uRoughess;
  float specular_colour = uReflectivity;
  vec3 specular = vec3(0.0, 0.0, 0.0);
  float specular_term = 0.0;
  vec3 viewDirection = normalize(vEyePosition - vWorldPosition);
  
  vec3 normal = perturbNormal(viewDirection);

  vec3 diffuse = clamp(dot(normal, light_direction), 0.0, 1.0) * light_colour;
  
  specular_term = LightingFuncGGX(normal, viewDirection, light_direction, uRoughess, uReflectivity);
  specular = specular_term * light_colour;

  gl_FragColor = vec4(color * diffuse + specular, alpha);
}
""";