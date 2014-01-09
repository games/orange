part of orange;



class Bone {
  String name;
  Vector3 pos;
  Quaternion rot;
  Matrix4 bindPoseMat;
  Matrix4 boneMat;
  Vector3 worldPos;
  Quaternion worldRot;
  int parent;
  bool skinned;
}