part of orange;





class Node {
  String name;
  Vector3 position;
  Quaternion rotation;
  Matrix4 _localMatrix;
  Matrix4 worldMatrix;
  Node parent;
  List<Node> children;
  
  Node() {
    position = new Vector3.zero();
    rotation = new Quaternion.identity();
    _localMatrix = new Matrix4.identity();
    worldMatrix = new Matrix4.identity();
    children = [];
  }
  
  destroy() {
    //TODO destroy buffers
  }
  
  add(Node child) {
    child.removeFromParent();
    child.parent = this;
    children.add(child);
  }
  
  removeFromParent() {
    if(parent != null) {
      parent.children.remove(this);
      parent = null;
    }
  }
  
  applyMatrix(Matrix4 m) {
    _localMatrix.multiply(m);
    _localMatrix.decompose(position, rotation);
  }
  
  updateMatrix() {
    _localMatrix.fromRotationTranslation(rotation, position);
    if(parent != null) {
      worldMatrix = parent.worldMatrix * _localMatrix;
    } else {
      worldMatrix = _localMatrix.clone();
    }
    children.forEach((c) => c.updateMatrix());
  }
}





































