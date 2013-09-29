part of orange;


class Transform {
  
  String name;
  
  Vector3 position;
  Vector3 scale;
  Quaternion rotation;
  
  Vector3 _worldPosition;
  
  Matrix4 matrix;
  Matrix4 _globalMatrix;
  Matrix4 _normalMatrix;
  
  Transform parent;
  
  List<Transform> children;
  
  Transform() {
    position = new Vector3.zero();
    scale = new Vector3(1.0, 1.0, 1.0);
    rotation = new Quaternion.identity();
    children = new List();
    matrix = new Matrix4.identity();
  }
  
  find(String name) {
    return children.firstWhere((e) => e.name == name);
  }
  
  add(Transform child) {
    child.removeFromParent();
    child.parent = this;
    children.add(child);
    if(child.name == null) {
      child.name = "Mesh ${children.length}";
    }
  }
  
  remove(Transform child) {
    children.remove(child);
    child.parent = null;
  }
  
  
  removeFromParent() {
    if(parent != null)
      parent.remove(this);
  }
  
  render() {
    children.forEach((e) => e.render());
  }
  
  updateMatrix() {
    matrix.setFromTranslationRotation(position, rotation);
    matrix.scale(scale);
  }
}












