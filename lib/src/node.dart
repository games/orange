part of orange;


class Node {
  String name;
  List<Node> children;
  List<String> childNames;
  Matrix4 _matrix;
  List<Mesh> meshes;
  
  Node parent;
  Matrix4 matrixWorld;
  
  Node() {
    children = new List();
    _matrix = new Matrix4.identity();
    matrixWorld = new Matrix4.identity();
    meshes = new List();
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
  
  translate(Vector3 translation) {
    _matrix.translate(translation);
  }
  
  scale(dynamic x, [double y = null, double z = null]) {
    _matrix.scale(x, y, z);
  }
  
  rotate(double angle, Vector3 axis) {
    _matrix.rotate(angle, axis);
  }
  
  rotateX(double rad) {
    _matrix.rotateX(rad);
  }
  
  rotateY(double rad) {
    _matrix.rotateY(rad);
  }
  
  rotateZ(double rad) {
    _matrix.rotateZ(rad);
  }
  
  applyMatrix(Matrix4 m) {
    _matrix.multiply(m);
  }
  
  updateMatrixWorld() {
    if(parent != null) {
      matrixWorld = parent.matrixWorld * _matrix;
    } else {
      matrixWorld = _matrix.clone();
    }
    children.forEach((c) => c.updateMatrixWorld());
  }
  
  Vector3 get translation => _matrix.getTranslation();
  Vector3 get scaling => _matrix.getScale();
}
