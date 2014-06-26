part of orange;





class Node {
  String id;
  Scene _scene;
  Vector3 _position;
  Vector3 _scaling;
  Quaternion _rotation;
  Matrix4 _localMatrix;
  Matrix4 worldMatrix;
  Node parent;
  List<Node> children;
  bool _needsUpdateLocalMatrix;

  Node({this.id}) {
    _position = new Vector3.zero();
    _scaling = new Vector3.all(1.0);
    _rotation = new Quaternion.identity();
    _localMatrix = new Matrix4.identity();
    _needsUpdateLocalMatrix = true;
    worldMatrix = new Matrix4.identity();
    children = [];
  }

  Vector3 get position => _position;
  Vector3 get scaling => _scaling;
  Quaternion get rotation => _rotation;

  void set scaling(Vector3 val) {
    val.copyInto(_scaling);
    _needsUpdateLocalMatrix = true;
  }

  void set rotation(Quaternion val) {
    val.copyTo(_rotation);
    _needsUpdateLocalMatrix = true;
  }

  void set position(Vector3 val) {
    val.copyInto(_position);
    _needsUpdateLocalMatrix = true;
  }

  void translate(dynamic x, [double y = 0.0, double z = 0.0]) {
    if (x is Vector3) {
      _position.add(x);
    } else {
      _position.x += x;
      _position.y += y;
      _position.z += z;
    }
    _needsUpdateLocalMatrix = true;
  }

  void rotate(Vector3 axis, double radians) {
    _rotation.setAxisAngle(axis, radians);
    _needsUpdateLocalMatrix = true;
  }

  void rotateX(double rad) {
    MathUtils.rotateX(_rotation, rad);
    _needsUpdateLocalMatrix = true;
  }

  void rotateY(double rad) {
    MathUtils.rotateY(_rotation, rad);
    _needsUpdateLocalMatrix = true;
  }

  void rotateZ(double rad) {
    MathUtils.rotateZ(_rotation, rad);
    _needsUpdateLocalMatrix = true;
  }

  void scale(dynamic val) {
    if (val is Vector3) {
      _scaling.multiply(val);
    } else {
      _scaling.scale(val);
    }
    _needsUpdateLocalMatrix = true;
  }

  void setTranslation(double x, double y, double z) {
    _position.setValues(x, y, z);
    _needsUpdateLocalMatrix = true;
  }

  void setQuaternion(double x, double y, double z, double w) {
    _rotation.x = x;
    _rotation.y = y;
    _rotation.z = z;
    _rotation.w = w;
    _needsUpdateLocalMatrix = true;
  }

  void setScaling(double x, double y, double z) {
    _scaling.setValues(x, y, z);
    _needsUpdateLocalMatrix = true;
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
    decompose(_localMatrix, position, _rotation, _scaling);
    _needsUpdateLocalMatrix = false;
  }

  updateMatrix([bool updateChildren = true]) {
    if (_needsUpdateLocalMatrix) {
      _localMatrix = recompose(_scaling, _rotation, position);
    }
    if (parent != null) {
      worldMatrix = parent.worldMatrix * _localMatrix;
    } else {
      worldMatrix = _localMatrix.clone();
    }
    if (updateChildren) children.forEach((c) => c.updateMatrix(updateChildren));
  }

  Scene get scene => _scene;

  void set scene(Scene val) {
    _scene = val;
    children.forEach((c) => c.scene = val);
  }

  Node clone() {
    var result = new Node();
    result.id = id;
    result.applyMatrix(_localMatrix);
    result._scaling = _scaling.clone();
    children.forEach((c) => result.add(c.clone()));
    return result;
  }

  void dispose() {
  }
}



















