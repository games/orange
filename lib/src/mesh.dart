part of orange;



class Mesh extends Node {

  static int BILLBOARDMODE_NONE = 0;
  static int BILLBOARDMODE_X = 1;
  static int BILLBOARDMODE_Y = 2;
  static int BILLBOARDMODE_Z = 4;
  static int BILLBOARDMODE_ALL = 7;

  VertexBuffer _faces;
  Geometry _geometry;
  Material material;
  Skeleton _skeleton;
  AnimationController animator;
  int primitive = gl.TRIANGLES;

  int _billboardMode = BILLBOARDMODE_NONE;
  Matrix4 _rotateYByPI = new Matrix4.rotationY(math.PI);
  Matrix4 _localBillboard = new Matrix4.zero();
  Matrix4 _pivotMatrix = new Matrix4.identity();
  Matrix4 _localScaling = new Matrix4.identity();
  Matrix4 _localRotation = new Matrix4.identity();
  Matrix4 _localTranslation = new Matrix4.identity();
  Matrix4 _localPivotScaling;
  Matrix4 _localPivotScalingRotation;

  bool _castShadows = false;
  bool _receiveShadows = false;
  bool showBoundingBox = false;
  bool _showSubBoundingBox = false;
  BoundingInfo _boundingInfo;

  int _physicImpostor = PhysicsEngine.NoImpostor;
  double physicsMass = 0.0;
  double physicsFriction = 0.0;
  double physicsRestitution = 0.0;

  double visibility = 1.0;
  
  double _distanceToCamera = 0.0;
  
  Collider _collider = new Collider();
  List _trianglePlanes;
  Vector3 ellipsoid = new Vector3(0.5, 1.0, 0.5);
  Vector3 ellipsoidOffset = new Vector3.zero();
  bool checkCollisions = false;

  Mesh({String name}) : super(id: name);

  @override
  updateMatrix([bool updateChildren = true]) {

    if (_needsUpdateLocalMatrix || _billboardMode != BILLBOARDMODE_NONE) {
      _localScaling.setIdentity();
      _localScaling[0] = _scaling.x;
      _localScaling[5] = _scaling.y;
      _localScaling[10] = _scaling.z;
      _localScaling[15] = 1.0;

      _localRotation.setIdentity().setRotation(_rotation.asRotationMatrix());

      _localTranslation.setIdentity().setTranslation(_position);

      _localPivotScaling = _localScaling * _pivotMatrix;
      _localPivotScalingRotation = _localRotation * _localPivotScaling;

      if (_billboardMode != BILLBOARDMODE_NONE) {
        var localPosition = _position.clone();
        var zero = scene.camera.position.clone();
        if (parent != null && parent.position != null) {
          localPosition.add(parent.position);
          _localTranslation.setTranslation(localPosition);
        }
        if (_billboardMode & BILLBOARDMODE_ALL == BILLBOARDMODE_ALL) {
          zero = scene.camera.position;
        } else {
          if (_billboardMode & BILLBOARDMODE_X == BILLBOARDMODE_X) zero.x = localPosition.x + Orange.Epsilon;
          if (_billboardMode & BILLBOARDMODE_Y == BILLBOARDMODE_Y) zero.y = localPosition.y + Orange.Epsilon;
          if (_billboardMode & BILLBOARDMODE_Z == BILLBOARDMODE_Z) zero.z = localPosition.z + Orange.Epsilon;
        }
        setViewMatrix(_localBillboard, localPosition, zero, Axis.UP);
        _localBillboard[12] = _localBillboard[13] = _localBillboard[14] = 0.0;
        _localBillboard.invert();
        _localMatrix = _localBillboard * _localPivotScalingRotation;
        _localPivotScalingRotation = _localMatrix * _rotateYByPI;
      }

      _localMatrix = _localTranslation * _localPivotScalingRotation;
      _needsUpdateLocalMatrix = false;
    }

    if (parent != null && _billboardMode == BILLBOARDMODE_NONE) {
      worldMatrix = parent.worldMatrix * _localMatrix;
    } else {
      worldMatrix = _localMatrix.clone();
    }
    _worldPosition.setValues(worldMatrix[12], worldMatrix[13], worldMatrix[14]);
    
    _updateBoundingInfo();

    if (updateChildren) children.forEach((c) => c.updateMatrix(updateChildren));

    // super.updateMatrix(updateChildren);
    // _updateBoundingInfo();
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

  bool get showSubBoundingBox => _showSubBoundingBox;

  void set showSubBoundingBox(bool val) {
    _showSubBoundingBox = val;
    children.forEach((c) {
      if (c is Mesh) {
        c.showBoundingBox = val;
        c.showSubBoundingBox = val;
      }
    });
  }

  int get billboardMode => _billboardMode;

  void set billboardMode(int val) {
    _billboardMode = val;
    _needsUpdateLocalMatrix = true;
  }
  
  void moveWithCollisions(Vector3 velocity) {
    var pos = _worldPosition - new Vector3(0.0, ellipsoid.y, 0.0);
    pos.add(ellipsoidOffset);
    _collider.radius = ellipsoid;
    
    var newPos = new Vector3.zero();
    _scene._getNewPosition(pos, velocity, _collider, 3, newPos, this);
    var pos2 = newPos - pos;
    if(pos2.length > Orange.CollisionsEpsilon) {
      _position.add(pos2);
    }
  }
  
  _checkCollision(Collider collider) {
    if(!_boundingInfo._checkCollision(collider)) return;
    
    // TODO
  }

  Node clone() {
    var result = new Mesh();
    result.id = id;
    result.applyMatrix(_localMatrix);
    result._scaling = _scaling.clone();
    result._position = _position.clone();
    result._rotation = _rotation.clone();
    result._billboardMode = _billboardMode;
    result._pivotMatrix = _pivotMatrix.clone();
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
