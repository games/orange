part of orange;



class Joint extends Node {
  int id;
  int parentId;
  Matrix4 _bindPoseMatrix;
  Matrix4 _inverseBindMatrix;
  
  updateMatrix() {
    super.updateMatrix();
    if(_bindPoseMatrix == null) {
      _bindPoseMatrix = _localMatrix.clone();
    }
    if(_inverseBindMatrix == null) {
      _inverseBindMatrix = worldMatrix.clone();
      _inverseBindMatrix.invert();
    }
  }
}