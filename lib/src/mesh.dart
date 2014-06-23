part of orange;



class Mesh extends Node {

  static const PRIMITIVE_POINTS = 0;
  static const PRIMITIVE_LINES = 1;
  static const PRIMITIVE_LINE_LOOP = 2;
  static const PRIMITIVE_LINE_STRIP = 3;
  static const PRIMITIVE_TRIANGLES = 4;
  static const PRIMITIVE_TRIANGLE_STRIP = 5;
  static const PRIMITIVE_TRIANGLE_FAN = 6;

  Geometry _geometry;
  VertexBuffer faces;
  Material material;
  Skeleton _skeleton;
  AnimationController animator;
  // TODO need change to real primitive type
  int primitive = PRIMITIVE_TRIANGLES;

  bool _castShadows = false;
  bool _receiveShadows = false;
  bool showBoundingBox = false;
  BoundingInfo _boundingInfo;
  int _physicImpostor = PhysicsEngine.NoImpostor;

  Mesh({String name}) : super(name: name);

  @override
  updateMatrix() {
    super.updateMatrix();
    _updateBoundingInfo();
  }

  void _updateBoundingInfo() {
    if (_geometry == null) return;
    if (_boundingInfo == null) {
      _boundingInfo = _geometry.boundingInfo;
      if (_boundingInfo == null) {
        var pos = worldMatrix.getTranslation();
        _boundingInfo = new BoundingInfo(pos, pos);
      }
    }
    _boundingInfo._update(worldMatrix);
  }

  BoundingInfo get boundingInfo => _boundingInfo;
  
  void set boundingInfo(BoundingInfo val) {
    _boundingInfo = val;
  }

  void setPhysicsState(int impostor, [PhysicsBodyCreationOptions options]) {
    var scene = Director.instance.scene;
    if (!scene.physicsEnabled) return;
    var physics = scene.physicsEngine;
    _physicImpostor = impostor;
    if (impostor == PhysicsEngine.NoImpostor) {
      physics._unregisterMesh(this);
      return;
    }
    physics._registerMesh(this, impostor, options);
  }

  void setPhysicsLinkWith(Mesh other, Vector3 pivot1, Vector3 pivot2) {
    if (_physicImpostor == PhysicsEngine.NoImpostor) return;
    Director.instance.scene.physicsEngine._createLink(this, other, pivot1, pivot2);
  }

  void applyImpulse(Vector3 force, Vector3 contactPoint) {
    if (_physicImpostor == PhysicsEngine.NoImpostor) return;
    Director.instance.scene.physicsEngine._applyImpulse(this, force, contactPoint);
  }

  Geometry get geometry {
    if (_geometry == null && parent != null && parent is Mesh) return (parent as Mesh).geometry;
    return _geometry;
  }

  void set geometry(Geometry val) {
    _geometry = val;
    _boundingInfo = _geometry.boundingInfo;
  }

  void set indices(data) {
    if (data is VertexBuffer) {
      faces = data;
      return;
    }
    if (!(data is Uint16List)) data = new Uint16List.fromList(data);
    faces = new VertexBuffer(0, gl.UNSIGNED_SHORT, 0, 0, count: data.length, data: data, target: gl.ELEMENT_ARRAY_BUFFER);
  }

  VertexBuffer get indices => faces;

  Skeleton get skeleton {
    if (_skeleton == null && parent != null && parent is Mesh) return (parent as Mesh)._skeleton;
    return _skeleton;
  }

  void set skeleton(Skeleton val) {
    _skeleton = val;
  }

  bool get castShadows => _castShadows;

  void set castShadows(bool val) {
    _castShadows = val;
    children.forEach((c) {
      if (c is Mesh) c._castShadows = val;
    });
  }

  bool get receiveShadows => _receiveShadows;

  void set receiveShadows(bool val) {
    _receiveShadows = val;
    children.forEach((c) {
      if (c is Mesh) c.receiveShadows = val;
    });
  }
}
