part of orange;



class Joint {
  String name;
  Vector3 pos;
  Quaternion rot;
  Matrix4 bindPoseMat;
  Matrix4 jointMat;
  Vector3 worldPos;
  Quaternion worldRot;
  int parent;
  bool skinned;
}