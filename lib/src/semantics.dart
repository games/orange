part of orange;





class Semantics {
// from : https://github.com/KhronosGroup/glTF/issues/83#issuecomment-24095883
//  static const String MODEL = "MODEL";
//  static const String VIEW = "VIEW";
//  static const String PROJECTION = "PROJECTION";
//  static const String MODELVIEW = "MODELVIEW";
//  static const String MODELVIEWPROJECTION = "MODELVIEWPROJECTION";
//  static const String MODELINVERSE = "MODELINVERSE";
//  static const String VIEWINVERSE = "VIEWINVERSE";
//  static const String PROJECTIONINVERSE = "PROJECTIONINVERSE";
//  static const String MODELVIEWINVERSE = "MODELVIEWINVERSE";
//  static const String MODELVIEWPROJECTIONINVERSE = "MODELVIEWPROJECTIONINVERSE";
//  static const String MODELINVERSETRANSPOSE = "MODELINVERSETRANSPOSE";
//  static const String MODELVIEWINVERSETRANSPOSE = "MODELVIEWINVERSETRANSPOSE";
//  static const String VIEWPORT = "VIEWPORT";
  
  
  static const String position = "position";
  static const String texcoords = "uv";
  static const String texcoords2 = "uv2";
  static const String normal = "normal";
  static const String indices = "indices";
  static const String tangent = "tangent";
  static const String color = "color";
  // BONES
  static const String weights = "matricesWeights";
  static const String joints = "matricesIndices";
  static const String jointMat = "mBones";
  
  static const String viewMat = "view";
  static const String viewProjectionMat = "viewProjection";
  static const String projectionMat = "projectionMat";
  static const String worldViewProjection = "worldViewProjection";
  static const String modelMat = "world";
  static const String normalMat = "uNormalMat";
  static const String cameraPosition = "vEyePosition";
  
  static const String texture = "diffuseSampler";
  static const String useTextures = "uUseTextures";
  static const String emissiveColor = "vEmissiveColor";
  static const String specularColor = "vSpecularColor";
  static const String ambientColor = "vAmbientColor";
  static const String diffuseColor = "vDiffuseColor";
  static const String shininess = "shininess";
}



















