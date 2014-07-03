part of orange;




class ArcRotateController implements CameraController {

  Camera camera;
  html.Element element;

  double _alpha = 0.0;
  double _beta = 0.0;
  double _radius = 0.0;

  double _inertialAlphaOffset = 0.0;
  double _inertialBetaOffset = 0.0;
  double _inertialRadiusOffset = 0.0;

  double inertia = 0.9;
  double lowerAlphaLimit;
  double upperAlphaLimit;
  double lowerBetaLimit = Orange.Epsilon;
  double upperBetaLimit = math.PI - Orange.Epsilon;
  double lowerRadiusLimit = Orange.Epsilon;
  double upperRadiusLimit;
  double angularSensibility = 1000.0;

  StreamSubscription _contextMenuSubscription;
  StreamSubscription _mouseDownSubscription;
  StreamSubscription _mouseMoveSubscription;
  StreamSubscription _mouseUpSubscription;
  StreamSubscription _mouseWheelSubscription;
  
  bool _mouseDown = false;

  @override
  void attach(Camera camera, html.Element element) {
    detach();
    camera.controller = this;
    _contextMenuSubscription = element.onContextMenu.listen((e) => e.preventDefault());
    _mouseDownSubscription = element.onMouseDown.listen(_onMouseDown);
    _mouseWheelSubscription = element.onMouseWheel.listen(_onMouseWheel);
    this.camera = camera;
    this.element = element;
    _init();
  }

  _init() {
    var radiusv3 = camera.position - camera.target;
    _radius = radiusv3.length;
    _alpha = math.acos(radiusv3.x / math.sqrt(math.pow(radiusv3.x, 2) + math.pow(radiusv3.z, 2)));
    if (radiusv3.z < 0) {
      _alpha = 2 * math.PI - _alpha;
    }
    _beta = math.acos(radiusv3.y / _radius);
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
    _init();
    
    if (_inertialAlphaOffset != 0 || _inertialBetaOffset != 0 || _inertialRadiusOffset != 0) {
      _alpha += _inertialAlphaOffset;
      _beta += _inertialBetaOffset;
      _radius -= _inertialRadiusOffset;

      _inertialAlphaOffset *= inertia;
      _inertialBetaOffset *= inertia;
      _inertialRadiusOffset *= inertia;

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
    var offset = new Vector3(_radius * cosa * sinb, _radius * cosb, _radius * sina * sinb);
    camera.position = camera.target + offset;
    camera.lookAt(camera.target);
  }

  void _onMouseDown(html.MouseEvent event) {
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
    _mouseMoveSubscription = html.document.onMouseMove.listen(_onMouseMove);
    _mouseUpSubscription = html.document.onMouseUp.listen(_onMouseUp);
    _mouseDown = true;
    event.preventDefault();
  }

  void _onMouseWheel(html.WheelEvent event) {
    var delta = event.deltaY / 200.0;
    _inertialRadiusOffset += delta;
    event.preventDefault();
  }

  void _onMouseMove(html.MouseEvent event) {
    if(!_mouseDown) return;
    var offsetX = event.movement.x;
    var offsetY = event.movement.y;
    _inertialAlphaOffset += offsetX / angularSensibility;
    _inertialBetaOffset -= offsetY / angularSensibility;
    event.preventDefault();
  }

  void _onMouseUp(html.MouseEvent event) {
    _mouseDown = false;
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
    event.preventDefault();
  }
}













