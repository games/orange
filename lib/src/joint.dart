part of orange;



class Joint extends Node {
  int id;
  int parentId;
  Matrix4 bindPostMatrix;
  Matrix4 inverseBindMatrix;
  
  Vector3 originPos;
  Quaternion originRot;
  
  updateMatrix() {
    super.updateMatrix();
    if(originPos == null) {
      originPos = position;
      originRot = rotation;
    }
    if(bindPostMatrix == null) {
      bindPostMatrix = worldMatrix;
    }
    if(inverseBindMatrix == null) {
      inverseBindMatrix = bindPostMatrix.clone();
      inverseBindMatrix.invert();
    }
  }
}