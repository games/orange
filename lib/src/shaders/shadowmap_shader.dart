part of orange;




const SHADER_SHADOW_VS = """
#ifdef GL_ES
precision mediump float;
#endif

// Attribute
attribute vec3 position;
#ifdef BONES
attribute vec4 matricesIndices;
attribute vec4 matricesWeights;
#endif

// Uniform
#ifdef INSTANCES
attribute vec4 world0;
attribute vec4 world1;
attribute vec4 world2;
attribute vec4 world3;
#else
uniform mat4 world;
#endif

uniform mat4 viewProjection;
#ifdef BONES
uniform mat4 mBones[BonesPerMesh];
#endif

#ifndef VSM
varying vec4 vPosition;
#endif

#ifdef ALPHATEST
varying vec2 vUV;
uniform mat4 diffuseMatrix;
#ifdef UV1
attribute vec2 uv;
#endif
#ifdef UV2
attribute vec2 uv2;
#endif
#endif

void main(void)
{
#ifdef INSTANCES
  mat4 finalWorld = mat4(world0, world1, world2, world3);
#else
  mat4 finalWorld = world;
#endif

#ifdef BONES
  mat4 m0 = mBones[int(matricesIndices.x)] * matricesWeights.x;
  mat4 m1 = mBones[int(matricesIndices.y)] * matricesWeights.y;
  mat4 m2 = mBones[int(matricesIndices.z)] * matricesWeights.z;
  mat4 m3 = mBones[int(matricesIndices.w)] * matricesWeights.w;
  finalWorld = finalWorld * (m0 + m1 + m2 + m3);
  gl_Position = viewProjection * finalWorld * vec4(position, 1.0);
#else
#ifndef VSM
  vPosition = viewProjection * finalWorld * vec4(position, 1.0);
#endif
  gl_Position = viewProjection * finalWorld * vec4(position, 1.0);
#endif

#ifdef ALPHATEST
#ifdef UV1
  vUV = vec2(diffuseMatrix * vec4(uv, 1.0, 0.0));
#endif
#ifdef UV2
  vUV = vec2(diffuseMatrix * vec4(uv2, 1.0, 0.0));
#endif
#endif
}
""";




const SHADER_SHADOW_FS = """
#ifdef GL_ES
precision mediump float;
#endif

vec4 pack(float depth)
{
  const vec4 bitOffset = vec4(255. * 255. * 255., 255. * 255., 255., 1.);
  const vec4 bitMask = vec4(0., 1. / 255., 1. / 255., 1. / 255.);
  
  vec4 comp = mod(depth * bitOffset * vec4(254.), vec4(255.)) / vec4(254.);
  comp -= comp.xxyz * bitMask;
  
  return comp;
}

// Thanks to http://devmaster.net/
vec2 packHalf(float depth) 
{ 
  const vec2 bitOffset = vec2(1.0 / 255., 0.);
  vec2 color = vec2(depth, fract(depth * 255.));

  return color - (color.yy * bitOffset);
}

#ifndef VSM
varying vec4 vPosition;
#endif

#ifdef ALPHATEST
varying vec2 vUV;
uniform sampler2D diffuseSampler;
#endif

void main(void)
{
#ifdef ALPHATEST
  if (texture2D(diffuseSampler, vUV).a < 0.4)
    discard;
#endif

#ifdef VSM
  float moment1 = gl_FragCoord.z / gl_FragCoord.w;
  float moment2 = moment1 * moment1;
  gl_FragColor = vec4(packHalf(moment1), packHalf(moment2));
#else
  gl_FragColor = pack(vPosition.z / vPosition.w);
#endif
}
""";
