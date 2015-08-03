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

  export enum BlendMode {
    ZERO,
    ONE,
    SRC_COLOR,
    ONE_MINUS_SRC_COLOR,
    DST_COLOR,
    ONE_MINUS_DST_COLOR,
    SRC_ALPHA,
    SRC_ALPHA_SATURATE,
    ONE_MINUS_SRC_ALPHA,
    DST_ALPHA,
    ONE_MINUS_DST_ALPHA
  }

  export enum BlendEquation {
    ADD,
    SUBTRACT,
    REVERSE_SUBTRACT
  }

  export enum BufferUsage {
    STATIC,
    DYNAMIC,
    STREAM
  }

  export enum ElementType {
    INT8,
    UINT8,
    INT16,
    UINT16,
    INT32,
    UINT32,
    FLOAT32
  }

  export enum Filter {
    NEAREST,
    LINEAR,
    NEAREST_MIPMAP_NEAREST,
    LINEAR_MIPMAP_NEAREST,
    LINEAR_MIPMAP_LINEAR
  }

  export enum IndexFormat {
    UINT8,
    UINT16,
    UINT32
  }

  export enum PixelFormat {
    A8,
    L8,
    L8_A8,
    R5_G6_B5,
    R5_G5_B5_A1,
    R4_G4_B4_A4,
    R8_G8_B8,
    R8_G8_B8_A8,
    DXT1,
    DXT3,
    DXT5,
    RGB16F,
    RGBA16F,
    RGB32F,
    RGBA32F,
    ETC1
  }

  export enum Primitive {
    POINTS,
    LINES,
    LINELOOP,
    LINESTRIP,
    TRIANGLES,
    TRISTRIP,
    TRIFAN
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
