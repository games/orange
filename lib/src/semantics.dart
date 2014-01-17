part of orange;




// from : https://github.com/KhronosGroup/glTF/issues/83#issuecomment-24095883
class Semantics {
  static const String MODEL = "MODEL";
  static const String VIEW = "VIEW";
  static const String PROJECTION = "PROJECTION";
  static const String MODELVIEW = "MODELVIEW";
  static const String MODELVIEWPROJECTION = "MODELVIEWPROJECTION";
  static const String MODELINVERSE = "MODELINVERSE";
  static const String VIEWINVERSE = "VIEWINVERSE";
  static const String PROJECTIONINVERSE = "PROJECTIONINVERSE";
  static const String MODELVIEWINVERSE = "MODELVIEWINVERSE";
  static const String MODELVIEWPROJECTIONINVERSE = "MODELVIEWPROJECTIONINVERSE";
  static const String MODELINVERSETRANSPOSE = "MODELINVERSETRANSPOSE";
  static const String MODELVIEWINVERSETRANSPOSE = "MODELVIEWINVERSETRANSPOSE";
  static const String VIEWPORT = "VIEWPORT";
  
  static const String position = "aPosition";
  static const String texture = "aTexture";
  static const String texture2 = "aTexture2";
  static const String normal = "aNormal";
  static const String tangent = "aTangent";
  static const String color = "aColor";
  static const String weights = "aWeights";
  static const String joints = "aJoints";
  
  static const String emissive = "emissive";
  static const String specular = "specular";
  static const String ambient = "ambient";
  static const String diffuse = "diffuse";
}