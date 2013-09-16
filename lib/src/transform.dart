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
  
  Quaternion _quaternion;
  
  Transform parent;
  
  List<Transform> children;
  
  Transform() {
    position = new Vector3.zero();
    rotation = new Vector3.zero();
    scale = new Vector3(1.0, 1.0, 1.0);
    children = new List();
    matrix = new Matrix4.identity();
  }
  
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
  
  render() {
    children.forEach((e) => e.render());
  }
  
  updateMatrix() {
    matrix.setIdentity();
    matrix.translate(position);
    matrix.scale(scale);
    matrix.rotateX(rotation.x);
    matrix.rotateY(rotation.y);
    matrix.rotateZ(rotation.z);
  }
}












