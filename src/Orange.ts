module orange {

  export enum CullMode {
    CULLFACE_NONE = 0,
    CULLFACE_FRONT = 1,
    CULLFACE_BACK = 2,
    CULLFACE_FRONTANDBACK = 3
  }

  export enum ClearFlags {
    COLOR = 1,
    DEPTH = 2,
    STENCIL = 4
  }

  export enum UniformType {
    BOOL,
    INT,
    FLOAT,
    VEC2,
    VEC3,
    VEC4,
    IVEC2,
    IVEC3,
    IVEC4,
    BVEC2,
    BVEC3,
    BVEC4,
    MAT2,
    MAT3,
    MAT4,
    TEXTURE2D,
    TEXTURECUBE
  }

  export const SEMANTIC_POSITION = "POSITION";
  export const SEMANTIC_NORMAL = "NORMAL";
  export const SEMANTIC_TANGENT = "TANGENT";
  export const SEMANTIC_BLENDWEIGHT = "BLENDWEIGHT";
  export const SEMANTIC_BLENDINDICES = "BLENDINDICES";
  export const SEMANTIC_COLOR = "COLOR";
  export const SEMANTIC_TEXCOORD0 = "TEXCOORD0";
  export const SEMANTIC_TEXCOORD1 = "TEXCOORD1";
  export const SEMANTIC_TEXCOORD2 = "TEXCOORD2";
  export const SEMANTIC_TEXCOORD3 = "TEXCOORD3";
  export const SEMANTIC_TEXCOORD4 = "TEXCOORD4";
  export const SEMANTIC_TEXCOORD5 = "TEXCOORD5";
  export const SEMANTIC_TEXCOORD6 = "TEXCOORD6";
  export const SEMANTIC_TEXCOORD7 = "TEXCOORD7";
  export const SEMANTIC_ATTR0 = "ATTR0";
  export const SEMANTIC_ATTR1 = "ATTR1";
  export const SEMANTIC_ATTR2 = "ATTR2";
  export const SEMANTIC_ATTR3 = "ATTR3";
  export const SEMANTIC_ATTR4 = "ATTR4";
  export const SEMANTIC_ATTR5 = "ATTR5";
  export const SEMANTIC_ATTR6 = "ATTR6";
  export const SEMANTIC_ATTR7 = "ATTR7";
  export const SEMANTIC_ATTR8 = "ATTR8";
  export const SEMANTIC_ATTR9 = "ATTR9";
  export const SEMANTIC_ATTR10 = "ATTR10";
  export const SEMANTIC_ATTR11 = "ATTR11";
  export const SEMANTIC_ATTR12 = "ATTR12";
  export const SEMANTIC_ATTR13 = "ATTR13";
  export const SEMANTIC_ATTR14 = "ATTR14";
  export const SEMANTIC_ATTR15 = "ATTR15";
}
