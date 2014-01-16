part of orange;



class Joint extends Node {
  int id;
  int parentId;
  Matrix4 bindPoseMatrix;
  Matrix4 inverseBindMatrix;
  
  Vector3 originPos;
  Quaternion originRot;
  
  updateMatrix() {
    super.updateMatrix();
    if(originPos == null) {
      originPos = position;
      originRot = rotation;
    }
    if(bindPoseMatrix == null) {
      bindPoseMatrix = _localMatrix;
    }
    if(inverseBindMatrix == null) {
      inverseBindMatrix = worldMatrix.clone();
      inverseBindMatrix.invert();
    }
  }
}