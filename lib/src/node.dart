part of orange;





class Node {
  String name;
  Scene _scene;
  Vector3 position;
  Vector3 scaling;
  Quaternion rotation;
  Matrix4 _localMatrix;
  Matrix4 worldMatrix;
  Node parent;
  List<Node> children;
  bool _needsUpdateLocalMatrix;

  Node({this.name}) {
    position = new Vector3.zero();
    scaling = new Vector3.all(1.0);
    rotation = new Quaternion.identity();
    _localMatrix = new Matrix4.identity();
    _needsUpdateLocalMatrix = true;
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
    if (parent != null) {
      parent.children.remove(this);
      parent = null;
    }
  }

  applyMatrix(Matrix4 m) {
    _localMatrix.multiply(m);
//    position = _localMatrix.getTranslation();
//    rotation = new Quaternion.fromRotation(_localMatrix.getRotation());
    decompose(_localMatrix, position, rotation, scaling);
    // TODO
         _needsUpdateLocalMatrix = false;
  }

  updateMatrix() {
    if (_needsUpdateLocalMatrix) {
      _localMatrix.setFromTranslationRotation(position, rotation);
      _localMatrix.scale(scaling);
    }
    if (parent != null) {
      worldMatrix = parent.worldMatrix * _localMatrix;
    } else {
      worldMatrix = _localMatrix.clone();
    }
    children.forEach((c) => c.updateMatrix());
  }

  Scene get scene => _scene;

  void set scene(Scene val) {
    _scene = val;
    children.forEach((c) => c.scene = val);
  }

  Node clone() {
    var result = new Node();
    result.name = name;
    result.applyMatrix(_localMatrix);
    result.scaling = scaling.clone();
    children.forEach((c) => result.add(c.clone()));
    return result;
  }
}
































