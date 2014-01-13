part of orange;





class Node {
  String name;
  Vector3 pos;
  Quaternion rot;
  Matrix4 _localMatrix;
  Matrix4 worldMatrix;
  Node parent;
  List<Node> children;
  
  Node() {
    pos = new Vector3.zero();
    rot = new Quaternion.identity();
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
    m.decompose(pos, rot);
  }
  
  updateMatrix() {
    _localMatrix.fromRotationTranslation(rot, pos);
    if(parent != null) {
      worldMatrix = parent._localMatrix * worldMatrix;
    } else {
      worldMatrix = _localMatrix.clone();
    }
    children.forEach((c) => c.updateMatrix());
  }
}





































