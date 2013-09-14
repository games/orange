part of orange;


class Transform {
  
  String name;
  
  Vector3 position;
  Vector3 rotation;
  Vector3 scale;
  
  Vector3 _worldPosition;
  
  Matrix4 matrix;
  Matrix4 _globalMatrix;
  Matrix4 _normalMatrix;
  
  Transform parent;
  
  List<Transform> children;
  
  add(Transform child) {
    child.removeFromParent();
    child.parent = this;
    children.add(child);
  }
  
  remove(Transform child) {
    children.remove(child);
    child.parent = null;
  }
  
  
  removeFromParent() {
    if(parent != null)
      parent.remove(this);
  }
}












