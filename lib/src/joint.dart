part of orange;



class Joint extends Node {
  String name;
  Matrix4 bindPoseMat;
  Matrix4 jointMat;
  Vector3 worldPos;
  Quaternion worldRot;
  int parentId;
  bool skinned;
}