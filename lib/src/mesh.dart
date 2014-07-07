part of orange;



class Mesh extends Node {

  VertexBuffer _faces;
  Geometry _geometry;
  Material material;
  Skeleton _skeleton;
  AnimationController animator;
  int primitive = gl.TRIANGLES;

  bool _castShadows = false;
  bool _receiveShadows = false;
  bool showBoundingBox = false;
  BoundingInfo _boundingInfo;

  int _physicImpostor = PhysicsEngine.NoImpostor;
  double physicsMass = 0.0;
  double physicsFriction = 0.0;
  double physicsRestitution = 0.0;

  double visibility = 1.0;

  Mesh({String name}) : super(id: name);

  @override
  updateMatrix([bool updateChildren = true]) {
    super.updateMatrix(updateChildren);
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
    var scene = Orange.instance.scene;
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
    Orange.instance.scene.physicsEngine._createLink(this, other, pivot1, pivot2);
  }

  void applyImpulse(Vector3 force, Vector3 contactPoint) {
    if (_physicImpostor == PhysicsEngine.NoImpostor) return;
    Orange.instance.scene.physicsEngine._applyImpulse(this, force, contactPoint);
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
      _faces = data;
      return;
    }
    if (!(data is Uint16List)) data = new Uint16List.fromList(data);
    _faces = new VertexBuffer(0, gl.UNSIGNED_SHORT, 0, 0, count: data.length, data: data, target: gl.ELEMENT_ARRAY_BUFFER);
  }

  VertexBuffer get indices {
    if (_faces == null && _geometry != null) return _geometry.indices;
    return _faces;
  }

  Skeleton get skeleton {
    return _skeleton;
  }

  void set skeleton(Skeleton val) {
    _skeleton = val;
    children.forEach((c) {
      if (c is Mesh) c.skeleton = val;
    });
  }

  bool get castShadows => _castShadows;

  void set castShadows(bool val) {
    _castShadows = val;
    children.forEach((c) {
      if (c is Mesh) c.castShadows = val;
    });
  }

  bool get receiveShadows => _receiveShadows;

  void set receiveShadows(bool val) {
    _receiveShadows = val;
    children.forEach((c) {
      if (c is Mesh) c.receiveShadows = val;
    });
  }

  Node clone() {
    var result = new Mesh();
    result.id = id;
    result.applyMatrix(_localMatrix);
    result._scaling = _scaling.clone();
    if (_geometry != null) result._geometry = _geometry.clone();
    result._faces = _faces;
    result.material = material;
    result._skeleton = _skeleton;
    if (animator != null) result.animator = animator.clone(result);
    result.primitive = primitive;
    result._castShadows = _castShadows;
    result._receiveShadows = _receiveShadows;
    result.showBoundingBox = showBoundingBox;
    children.forEach((c) => result.add(c.clone()));
    return result;
  }

  @override
  void dispose() {
    //TODO dispose resources
  }
}


