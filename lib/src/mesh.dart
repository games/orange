part of orange;



class Mesh extends Node {
  String name;
  Geometry _geometry;
  BufferView faces;
  Material material;
  Skeleton _skeleton;
  AnimationController animator;

  bool _castShadows = false;
  bool _receiveShadows = false;
  bool showBoundingBox = false;
  BoundingInfo _boundingInfo;

  Mesh({String name}) : super(name: name);

  @override
  updateMatrix() {
    super.updateMatrix();
    _updateBoundingInfo();
  }

  void _updateBoundingInfo() {
    if(_geometry == null) return;
    if (_boundingInfo == null) {
      _boundingInfo = _geometry.boundingInfo;
      if (_boundingInfo == null) {
        var pos = worldMatrix.getTranslation();
        _boundingInfo = new BoundingInfo(pos, pos);
      }
    }
    _boundingInfo._update(worldMatrix);
    //    children.forEach((c) {
    //      if (c is Mesh) c._updateBoundingInfo();
    //    });
  }

  BoundingInfo get boundingInfo => _boundingInfo;

  void setPhysicsState(int impostor, [PhysicsBodyCreationOptions options]) {
    if (!scene.physicsEnabled) return;
    var physics = scene.physicsEngine;
    if (impostor == PhysicsEngine.NoImpostor) {
      physics._unregisterMesh(this);
      return;
    }
    physics._registerMesh(this, impostor, options);
  }

  Geometry get geometry {
    if (_geometry == null && parent != null && parent is Mesh) return (parent as Mesh).geometry;
    return _geometry;
  }

  void set geometry(Geometry val) {
    _geometry = val;
    _boundingInfo = _geometry.boundingInfo;
  }

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
