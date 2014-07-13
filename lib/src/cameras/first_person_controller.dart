part of orange;




class FreeCameraController extends CameraController {

  Camera camera;
  html.Element element;

  double movementSpeed = 0.05;
  double lookSpeed = 0.005;

  bool lookVertical = true;
  bool autoForward = false;

  bool activeLook = true;

  bool heightSpeed = false;
  double heightCoef = 1.0;
  double heightMin = 0.0;
  double heightMax = 1.0;

  bool constrainVertical = false;
  double verticalMin = 0.0;
  double verticalMax = math.PI;

  double autoSpeedFactor = 0.0;
  Vector2 mousePosition = new Vector2.zero();

  double lat = 0.0;
  double lon = 0.0;
  double phi = 0.0;
  double theta = 0.0;

  bool moveForward = false;
  bool moveBackward = false;
  bool moveLeft = false;
  bool moveRight = false;
  bool moveUp = false;
  bool moveDown = false;
  bool freeze = false;
  bool mouseDragOn = false;

  Vector2 viewHalf = new Vector2.zero();

  List<int> keysForward = [html.KeyCode.W, html.KeyCode.UP];
  List<int> keysBackward = [html.KeyCode.S, html.KeyCode.DOWN];
  List<int> keysLeft = [html.KeyCode.A, html.KeyCode.LEFT];
  List<int> keysRight = [html.KeyCode.D, html.KeyCode.RIGHT];
  List<int> keysUp = [html.KeyCode.R];
  List<int> keysDown = [html.KeyCode.F];
  List<int> keysFreeze = [html.KeyCode.Q];

  StreamSubscription _contextMenuSubscription;
  StreamSubscription _keydownSubscription;
  StreamSubscription _keyupSubscription;
  StreamSubscription _mouseDownSubscription;
  StreamSubscription _mouseMoveSubscription;
  StreamSubscription _mouseUpSubscription;

  @override
  void attach(Camera camera, html.Element element) {
    detach();
    camera.controller = this;
    _contextMenuSubscription = element.onContextMenu.listen((e) => e.preventDefault());
    _keydownSubscription = html.document.onKeyDown.listen(_onKeydown);
    _keyupSubscription = html.document.onKeyUp.listen(_onKeyup);
    _mouseDownSubscription = element.onMouseDown.listen(_onMouseDown);
    _mouseUpSubscription = element.onMouseUp.listen(_onMouseUp);
    _mouseMoveSubscription = element.onMouseMove.listen(_onMouseMove);
    this.camera = camera;
    this.element = element;
    if (element == html.document) {
      viewHalf.setValues(html.window.innerWidth / 2.0, html.window.innerHeight / 2.0);
    } else {
      viewHalf.setValues(element.offsetWidth / 2.0, element.offsetHeight / 2.0);
    }
  }

  @override
  void detach() {
    if (camera != null) camera.controller = null;
    if (_contextMenuSubscription != null) _contextMenuSubscription.cancel();
    if (_keydownSubscription != null) _keydownSubscription.cancel();
    if (_keyupSubscription != null) _keyupSubscription.cancel();
    if (_mouseDownSubscription != null) _mouseDownSubscription.cancel();
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
  }

  @override
  void update() {
    if (freeze) return;
    var delta = Orange.instance.deltaTime;
    if (heightSpeed) {
      var y = clampNumber(camera.position.y, heightMin, heightMax);
      var heightDelta = y - heightMin;
      autoSpeedFactor = delta * (heightDelta * heightCoef);
    } else {
      autoSpeedFactor = 0.0;
    }
    var actualMoveSpeed = delta * movementSpeed;

    if (moveForward || (autoForward && !moveBackward)) camera.translateZ(-(actualMoveSpeed + this.autoSpeedFactor));
    if (moveBackward) camera.translateZ(actualMoveSpeed);
    if (moveLeft) camera.translateX(-actualMoveSpeed);
    if (moveRight) camera.translateX(actualMoveSpeed);
    if (moveUp) camera.translateY(actualMoveSpeed);
    if (moveDown) camera.translateY(-actualMoveSpeed);

    var actualLookSpeed = 16 * lookSpeed;
    if (!activeLook) {
      actualLookSpeed = 0;
    }

    var verticalLookRatio = 1;
    if (constrainVertical) {
      verticalLookRatio = math.PI / (verticalMax - verticalMin);
    }

    lon = mousePosition.x * actualLookSpeed;
    if (lookVertical) lat = -mousePosition.y * actualLookSpeed * verticalLookRatio;

    lat = math.max(-85.0, math.min(85.0, lat));
    phi = radians(90 - lat);
    theta = radians(lon);

    if (constrainVertical) {
      phi = mapLinear(phi, 0.0, math.PI, verticalMin, verticalMax);
    }

    var targetPosition = camera.target,
        position = camera.position;

    targetPosition.x = position.x + 100 * math.sin(phi) * math.cos(theta);
    targetPosition.y = position.y + 100 * math.cos(phi);
    targetPosition.z = position.z + 100 * math.sin(phi) * math.sin(theta);

    camera.lookAt(targetPosition);
  }

  void _onKeydown(html.KeyboardEvent event) {
    if (keysBackward.contains(event.keyCode)) {
      moveBackward = true;
    } else if (keysLeft.contains(event.keyCode)) {
      moveLeft = true;
    } else if (keysRight.contains(event.keyCode)) {
      moveRight = true;
    } else if (keysForward.contains(event.keyCode)) {
      moveForward = true;
    } else if (keysUp.contains(event.keyCode)) {
      moveUp = true;
    } else if (keysDown.contains(event.keyCode)) {
      moveDown = true;
    } else if (keysFreeze.contains(event.keyCode)) {
      freeze = !freeze;
    }
  }

  void _onKeyup(html.KeyboardEvent event) {
    if (keysBackward.contains(event.keyCode)) {
      moveBackward = false;
    } else if (keysLeft.contains(event.keyCode)) {
      moveLeft = false;
    } else if (keysRight.contains(event.keyCode)) {
      moveRight = false;
    } else if (keysForward.contains(event.keyCode)) {
      moveForward = false;
    } else if (keysUp.contains(event.keyCode)) {
      moveUp = false;
    } else if (keysDown.contains(event.keyCode)) {
      moveDown = false;
    }
  }

  void _onMouseDown(html.MouseEvent event) {
    if (element != html.document) {
      element.focus();
    }
    if (activeLook) {
      switch (event.button) {
        case 0:
          moveForward = true;
          break;
        case 2:
          moveBackward = true;
          break;
      }
    }
    mouseDragOn = true;
    event.preventDefault();
    event.stopPropagation();
  }

  void _onMouseUp(html.MouseEvent event) {
    if (activeLook) {
      switch (event.button) {
        case 0:
          moveForward = false;
          break;
        case 2:
          moveBackward = false;
          break;
      }
    }
    mouseDragOn = false;
    event.preventDefault();
    event.stopPropagation();
  }

  void _onMouseMove(html.MouseEvent event) {
    
    if (!Orange.instance._isPointerLock) {
      if (element == html.document) {
        mousePosition.setValues(event.page.x - viewHalf.x, event.page.y - viewHalf.y);
      } else {
        mousePosition.setValues(event.page.x - element.offsetLeft - viewHalf.x, event.page.y - element.offsetTop - viewHalf.y);
      }
    } else {
      mousePosition.x += event.movement.x.toDouble();
      mousePosition.y += event.movement.y.toDouble();
    }

    event.preventDefault();
    event.stopPropagation();
  }
}










































class FreeCameraController2 extends CameraController {

  Camera camera;
  html.Element element;

  Vector3 cameraDirection = new Vector3.zero();
  Vector2 cameraRotation = new Vector2.zero();
  Vector3 rotation = new Vector3.zero();
  Vector3 ellipsoid = new Vector3(0.5, 1.0, 0.5);
  List<int> keysUp = [html.KeyCode.W, html.KeyCode.UP];
  List<int> keysDown = [html.KeyCode.S, html.KeyCode.DOWN];
  List<int> keysLeft = [html.KeyCode.A, html.KeyCode.LEFT];
  List<int> keysRight = [html.KeyCode.D, html.KeyCode.RIGHT];
  double speed = 2.0;
  double inertia = 0.9;
  bool checkCollisions = false;
  bool applyGravity = false;
  bool noRotationConstraint = false;
  double angularSensibility = 2000.0;
  // TODO
  dynamic lockedTarget;
  dynamic onCollide;

  List<int> _keys = [];
  Collider _collider = new Collider();
  bool _needMoveForGravity = true;
  Vector3 _currentTarget = new Vector3.zero();
  Vector2 _previousPosition;
  Vector2 _cameraRotation = new Vector2.zero();
  Vector3 _position = new Vector3.zero();
  Vector3 _rotation = new Vector3.zero();
  Vector3 _localDirection;
  Vector3 _transformedDirection;
  Vector3 _referencePoint = new Vector3.zero();
  Vector3 _transformedReferencePoint = new Vector3.zero();
  Matrix4 _cameraRotationMatrix = new Matrix4.zero();
  Matrix4 _cameraTransformMatrix = new Matrix4.zero();

  StreamSubscription _contextMenuSubscription;
  StreamSubscription _keydownSubscription;
  StreamSubscription _keyupSubscription;
  StreamSubscription _mouseDownSubscription;
  StreamSubscription _mouseMoveSubscription;
  StreamSubscription _mouseUpSubscription;
  StreamSubscription _mouseOutSubscription;
  StreamSubscription _mouseWheelSubscription;

  @override
  void attach(Camera camera, html.Element element) {
    detach();
    camera.controller = this;
    _contextMenuSubscription = element.onContextMenu.listen((e) => e.preventDefault());
    _keydownSubscription = element.onKeyDown.listen(_onKeydown);
    _keyupSubscription = element.onKeyUp.listen(_onKeyup);
    _mouseDownSubscription = element.onMouseDown.listen(_onMouseDown);
    _mouseUpSubscription = element.onMouseUp.listen(_onMouseUp);
    _mouseMoveSubscription = element.onMouseMove.listen(_onMouseMove);
    _mouseOutSubscription = element.onMouseOut.listen(_onMouseOut);
    _mouseWheelSubscription = element.onMouseWheel.listen(_onMouseWheel);
    this.camera = camera;
    this.element = element;
  }

  @override
  void detach() {
    if (camera != null) camera.controller = null;
    if (_contextMenuSubscription != null) _contextMenuSubscription.cancel();
    if (_keydownSubscription != null) _keydownSubscription.cancel();
    if (_keyupSubscription != null) _keyupSubscription.cancel();
    if (_mouseDownSubscription != null) _mouseDownSubscription.cancel();
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
    if (_mouseOutSubscription != null) _mouseOutSubscription.cancel();
    if (_mouseWheelSubscription != null) _mouseWheelSubscription.cancel();
  }

  @override
  void update() {
    _checkInputs();
    var needToMove = cameraDirection.x.abs() > 0 || cameraDirection.y.abs() > 0 || cameraDirection.z.abs() > 0;
    var needToRotate = cameraRotation.x.abs() > 0 || cameraRotation.y.abs() > 0;
    if (needToMove) {
      _position.add(cameraDirection);
    }
    if (needToRotate) {
      _rotation.x += cameraRotation.x;
      _rotation.y += cameraRotation.y;
      if (!noRotationConstraint) {
        var limit = (math.PI / 2) * 0.95;
        if (_rotation.x > limit) _rotation.x = limit;
        if (_rotation.x < -limit) _rotation.x = -limit;
      }
    }
    // inertia
    if (needToMove) {
      if (cameraDirection.x.abs() < Orange.Epsilon) cameraDirection.x = 0.0;
      if (cameraDirection.y.abs() < Orange.Epsilon) cameraDirection.y = 0.0;
      if (cameraDirection.z.abs() < Orange.Epsilon) cameraDirection.z = 0.0;
    }
    if (needToRotate) {
      if (cameraRotation.x.abs() < Orange.Epsilon) cameraRotation.x = 0.0;
      if (cameraRotation.y.abs() < Orange.Epsilon) cameraRotation.y = 0.0;
      cameraRotation.scale(inertia);
    }
  }

  void _checkInputs() {
    if (_localDirection == null) {
      _localDirection = new Vector3.zero();
      _transformedDirection = new Vector3.zero();
    }
    _keys.forEach((int keyCode) {
      var speed = _computeLocalCameraSpeed();
      if (keysLeft.contains(keyCode)) {
        _localDirection.setValues(-speed, 0.0, 0.0);
      } else if (keysUp.contains(keyCode)) {
        _localDirection.setValues(0.0, 0.0, speed);
      } else if (keysRight.contains(keyCode)) {
        _localDirection.setValues(speed, 0.0, 0.0);
      } else if (keysDown.contains(keyCode)) {
        _localDirection.setValues(0.0, 0.0, -speed);
      }

      _cameraTransformMatrix.copyInverse(_getViewMatrix());
      _transformedDirection = _cameraTransformMatrix * _localDirection;
      cameraDirection.add(_transformedDirection);
    });
  }

  Quaternion _tempRotation = new Quaternion.identity();

  Matrix4 _getViewMatrix() {
    _referencePoint.setValues(0.0, 0.0, 1.0);
    _tempRotation.setEuler(rotation.y, rotation.x, rotation.z);
    _cameraRotationMatrix.setIdentity().setRotation(_tempRotation.asRotationMatrix());
    _transformedReferencePoint = _cameraRotationMatrix * _referencePoint;
    _currentTarget = _position + _transformedReferencePoint;
    camera.position = _position;
    camera.lookAt(_currentTarget);
    return camera.viewMatrix;
  }

  double _computeLocalCameraSpeed() {
    return speed * (Orange.instance.deltaTime / (Orange.instance.fps * 10.0));
  }

  void _onKeydown(html.KeyboardEvent event) {
    if (keysDown.contains(event.keyCode) || keysLeft.contains(event.keyCode) || keysRight.contains(event.keyCode) || keysUp.contains(event.keyCode)) {
      var index = _keys.indexOf(event.keyCode);
      if (index == -1) {
        _keys.add(event.keyCode);
      }
      event.preventDefault();
    }
  }

  void _onKeyup(html.KeyboardEvent event) {
    if (keysDown.contains(event.keyCode) || keysLeft.contains(event.keyCode) || keysRight.contains(event.keyCode) || keysUp.contains(event.keyCode)) {
      var index = _keys.indexOf(event.keyCode);
      if (index >= 0) {
        _keys.remove(event.keyCode);
      }
      event.preventDefault();
    }
  }

  void _onMouseDown(html.MouseEvent event) {
    _previousPosition = new Vector2(event.client.x.toDouble(), event.client.y.toDouble());
    event.preventDefault();
  }

  void _onMouseUp(html.MouseEvent event) {
    _previousPosition = null;
  }

  void _onMouseWheel(html.WheelEvent event) {
  }

  void _onMouseOut(html.MouseEvent event) {
    _previousPosition = null;
    _keys = [];
    event.preventDefault();
  }

  void _onMouseMove(html.MouseEvent event) {
    if (_previousPosition == null) return;
    var offsetX, offsetY;
    if (!Orange.instance._isPointerLock) {
      offsetX = event.client.x - _previousPosition.x;
      offsetY = event.client.y - _previousPosition.y;
    } else {
      offsetX = event.movement.x;
      offsetY = event.movement.y;
    }
    _cameraRotation.y += offsetX / angularSensibility;
    _cameraRotation.x += offsetY / angularSensibility;
    _previousPosition.setValues(event.client.x.toDouble(), event.client.y.toDouble());
    event.preventDefault();
  }
}






