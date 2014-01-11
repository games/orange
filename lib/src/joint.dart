part of orange;



class Joint extends Node {
  String name;
  Vector3 pos;
  Quaternion rot;
  Matrix4 bindPoseMat;
  Matrix4 jointMat;
  Vector3 worldPos;
  Quaternion worldRot;
  int parentId;
  bool skinned;
  
  applyMatrix(Matrix4 m) {
    pos = new Vector3.zero();
    rot = new Quaternion.identity();
    m.decompose(pos, rot);
  }
}