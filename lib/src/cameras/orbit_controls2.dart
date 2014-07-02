part of orange;




class OrbitControls2 implements CameraController {

  Camera camera;
  html.Element element;

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
    if(_inertialAlphaOffset != 0 || _inertialBetaOffset != 0 || _inertialRadiusOffset != 0) {
      _alpha += _inertialAlphaOffset;
      _beta += _inertialBetaOffset;
      _radius -= _inertialRadiusOffset;
      
      _inertialAlphaOffset *= _inertia;
      _inertialBetaOffset *= _inertia;
      _inertialRadiusOffset *= _inertia;
      
      if(_inertialAlphaOffset.abs() < Orange.Epsilon) 
        _inertialAlphaOffset = 0.0;
      if(_inertialBetaOffset.abs() < Orange.Epsilon)
        _inertialBetaOffset = 0.0;
      if(_inertialRadiusOffset.abs() < Orange.Epsilon)
        _inertialRadiusOffset = 0.0;
    }
    
    if(_lowerAlphaLimit != 0 && _alpha < _lowerAlphaLimit) 
      _alpha = _lowerAlphaLimit;
    if(_upperAlphaLimit != 0 && _alpha > _upperAlphaLimit)
      _alpha = _upperAlphaLimit;
    if(_lowerBetaLimit != 0 && _beta < _lowerBetaLimit)
      _beta = _lowerBetaLimit;
    if(_upperBetaLimit != 0 && _beta > _upperBetaLimit)
      _beta = _upperBetaLimit;
    if(_lowerRadiusLimit != 0 && _radius < _lowerRadiusLimit)
      _radius = _lowerRadiusLimit;
    if(_upperRadiusLimit != 0 && _radius > _upperRadiusLimit)
      _radius = _upperRadiusLimit;
    
    
  }

  void _onMouseDown(html.MouseEvent event) {
    _previousPosition = new Vector2(event.client.x, event.client.y);
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
    _mouseMoveSubscription = html.document.onMouseMove.listen(_onMouseMove);
    _mouseUpSubscription = html.document.onMouseUp.listen(_onMouseUp);

    event.preventDefault();
  }

  void _onMouseWheel(html.WheelEvent event) {
    var delta = 0.0;
    
  }
  
  num _inertialAlphaOffset, _inertialBetaOffset, _inertialRadiusOffset;
  
  void _onMouseMove(html.MouseEvent event) {
    if(_previousPosition == null) return;
    var offsetX = event.client.x - _previousPosition.x;
    var offsetY = event.client.y - _previousPosition.y;
    _inertialAlphaOffset -= offsetX / angularSensibility;
    _inertialBetaOffset -= offsetY / angularSensibility;
    _previousPosition.setValues(event.client.x, event.client.y);
    event.preventDefault();
  }
  
  void _onMouseUp(html.MouseEvent event) {
    _previousPosition = null;
    event.preventDefault();
  }
}

















