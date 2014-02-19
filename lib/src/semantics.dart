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
  
  /// TODO should be rename to vertexes
  static const String position = "aPosition";
  static const String texcoords = "aTexture";
  static const String texcoords2 = "aTexture2";
  static const String normal = "aNormal";
  static const String tangent = "aTangent";
  static const String color = "aColor";
  static const String weights = "aWeights";
  static const String joints = "aJoints";
  
  static const String viewMat = "uViewMat";
  static const String projectionMat = "uProjectionMat";
  static const String modelMat = "uModelMat";
  static const String normalMat = "uNormalMat";
  static const String cameraPosition = "uCameraPosition";
  
  static const String texture = "texture";
  static const String emissiveColor = "emissiveColor";
  static const String specularColor = "specularColor";
  static const String ambientColor = "ambientColor";
  static const String diffuseColor = "diffuseColor";
  static const String shininess = "shininess";
}



















