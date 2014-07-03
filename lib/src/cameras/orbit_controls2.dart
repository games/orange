part of orange;




class OrbitControls2 implements CameraController {

  Camera camera;
  html.Element element;

  double _alpha = 0.0;
  double _beta = 0.0;
  double _radius = 0.0;
  double _inertia = 0.0;

  double _inertialAlphaOffset = 0.0;
  double _inertialBetaOffset = 0.0;
  double _inertialRadiusOffset = 0.0;

  double lowerAlphaLimit;
  double upperAlphaLimit;
  double lowerBetaLimit;
  double upperBetaLimit;
  double lowerRadiusLimit;
  double upperRadiusLimit;
  double angularSensibility = 1000.0;

  StreamSubscription _contextMenuSubscription;
  StreamSubscription _mouseDownSubscription;
  StreamSubscription _mouseMoveSubscription;
  StreamSubscription _mouseUpSubscription;
  StreamSubscription _mouseWheelSubscription;

  Vector2 _previousPosition;

  @override
  void attach(Camera camera, html.Element element) {
    detach();
    camera.controller = this;
    _contextMenuSubscription = element.onContextMenu.listen((e) => e.preventDefault());
    _mouseDownSubscription = element.onMouseDown.listen(_onMouseDown);
    _mouseWheelSubscription = element.onMouseWheel.listen(_onMouseWheel);

    this.camera = camera;
    this.element = element;
  }

  @override
  void detach() {
    if (camera != null) camera.controller = null;
    if (_contextMenuSubscription != null) _contextMenuSubscription.cancel();
    if (_mouseDownSubscription != null) _mouseDownSubscription.cancel();
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
    if (_mouseWheelSubscription != null) _mouseWheelSubscription.cancel();
  }

  @override
  void update() {
    if (_inertialAlphaOffset != 0 || _inertialBetaOffset != 0 || _inertialRadiusOffset != 0) {

      _alpha += _inertialAlphaOffset;
      _beta += _inertialBetaOffset;
      _radius -= _inertialRadiusOffset;

      _inertialAlphaOffset *= _inertia;
      _inertialBetaOffset *= _inertia;
      _inertialRadiusOffset *= _inertia;

      if (_inertialAlphaOffset.abs() < Orange.Epsilon) _inertialAlphaOffset = 0.0;
      if (_inertialBetaOffset.abs() < Orange.Epsilon) _inertialBetaOffset = 0.0;
      if (_inertialRadiusOffset.abs() < Orange.Epsilon) _inertialRadiusOffset = 0.0;
    }

    if (lowerAlphaLimit != null && _alpha < lowerAlphaLimit) _alpha = lowerAlphaLimit;
    if (upperAlphaLimit != null && _alpha > upperAlphaLimit) _alpha = upperAlphaLimit;
    if (lowerBetaLimit != null && _beta < lowerBetaLimit) _beta = lowerBetaLimit;
    if (upperBetaLimit != null && _beta > upperBetaLimit) _beta = upperBetaLimit;
    if (lowerRadiusLimit != null && _radius < lowerRadiusLimit) _radius = lowerRadiusLimit;
    if (upperRadiusLimit != null && _radius > upperRadiusLimit) _radius = upperRadiusLimit;

    var cosa = math.cos(_alpha);
    var sina = math.sin(_alpha);
    var cosb = math.cos(_beta);
    var sinb = math.sin(_beta);
    
    var radiusv3 = camera.position - camera.target;
    var radius = radiusv3.length;
    var alpha = math.acos(radiusv3.x / math.sqrt(math.pow(radiusv3.x, 2) + math.pow(radiusv3.z, 2)));
    var beta = math.acos(radiusv3.y / radius);
    
    _radius += radius;
    _alpha += alpha;
    _beta += beta;
    
//    camera.position.add(new Vector3(_radius * cosa * sinb, _radius * cosb, _radius * sina * sinb));
    var offset = new Vector3(_radius * cosa * sinb, _radius * cosb, _radius * sina * sinb);
    print([_alpha, _beta, _radius]);
    camera.translate(offset);
    camera.lookAt(camera.target);
  }

  void _onMouseDown(html.MouseEvent event) {
    _previousPosition = new Vector2(event.client.x.toDouble(), event.client.y.toDouble());
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
    _mouseMoveSubscription = html.document.onMouseMove.listen(_onMouseMove);
    _mouseUpSubscription = html.document.onMouseUp.listen(_onMouseUp);

    event.preventDefault();
  }

  void _onMouseWheel(html.WheelEvent event) {
    var delta = 0.0;

  }

  void _onMouseMove(html.MouseEvent event) {
    if (_previousPosition == null) return;
    var offsetX = event.client.x - _previousPosition.x;
    var offsetY = event.client.y - _previousPosition.y;
    _inertialAlphaOffset -= offsetX / angularSensibility;
    _inertialBetaOffset -= offsetY / angularSensibility;
    _previousPosition.setValues(event.client.x.toDouble(), event.client.y.toDouble());
    event.preventDefault();
  }

  void _onMouseUp(html.MouseEvent event) {
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
    _previousPosition = null;
    event.preventDefault();
  }
}















