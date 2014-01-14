part of orange;



class Joint extends Node {
  int id;
  int parentId;
  Matrix4 inverseBindMatrix;
  
  updateMatrix() {
    super.updateMatrix();
    if(inverseBindMatrix == null) {
      inverseBindMatrix = worldMatrix.clone();
      inverseBindMatrix.invert();
    }
  }
}