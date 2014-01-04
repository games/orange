part of orange;


class Node {
  String name;
  List<Node> children;
  List<String> childNames;
  Matrix4 _matrix;
  Map instanceSkin;
  List<Mesh> meshes;
  
  Node parent;
  Matrix4 matrixWorld;
  
  Vector3 _position;
  Quaternion _rotation;
  Vector3 _scale;
  
  Node() {
    children = new List();
    _matrix = new Matrix4.identity();
    matrixWorld = new Matrix4.identity();
    meshes = new List();
    
    _position = new Vector3.zero();
    _rotation = new Quaternion.identity();
    _scale = new Vector3(1.0, 1.0, 1.0);
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
//    _matrix.decompose(_position, _rotation, _scale);
  }
  
  rotateY(double rad) {
    _matrix.rotateY(rad);
  }
  
  rotateZ(double rad) {
    _matrix.rotateZ(rad);
//    _matrix.decompose(_position, _rotation, _scale);
  }
  
  applyMatrix(Matrix4 m) {
    _matrix.multiply(m);
//    _matrix.decompose(_position, _rotation, _scale);
  }
  
  updateMatrixWorld() {
//    if(!(this is Camera)){
//    _matrix.fromRotationTranslation(_rotation, _position);
//    _matrix.scale(_scale);
//    }
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
