part of orange;



//
// from : http://tileableart.com/code/natureof/js/three/js/controls/OrbitControls.js
// TODO : update from https://github.com/mrdoob/three.js/blob/master/examples/js/controls/OrbitControls.js
//
class OrbitControls implements CameraController {

  static const STATE_NONE = -1;
  static const STATE_ROTATE = 0;
  static const STATE_ZOOM = 1;

  Camera object;
  html.Element element;
  Vector3 center = new Vector3.zero();
  bool userZoom = true;
  double userZoomSpeed = 1.0;
  bool userRotate = true;
  double userRotateSpeed = 1.0;
  bool autoRotate = false;
  double autoRotateSpeed = 2.0;
  double minPolarAngle = 0.0;
  double maxPolarAngle = math.PI;
  double minDistance = 0.0;
  double maxDistance = double.MAX_FINITE;

  double _EPS = 0.000001;
  double _PIXELS_PER_ROUND = 1800.0;
  Vector2 _rotateStart = new Vector2.zero();
  Vector2 _rotateEnd = new Vector2.zero();
  Vector2 _rotateDelta = new Vector2.zero();
  Vector2 _zoomStart = new Vector2.zero();
  Vector2 _zoomEnd = new Vector2.zero();
  Vector2 _zoomDelta = new Vector2.zero();
  double _phiDelta = 0.0;
  double _thetaDelta = 0.0;
  double _scale = 1.0;
  Vector3 _lastPosition = new Vector3.zero();
  int _state = STATE_NONE;

  StreamSubscription _contextMenuSubscription;
  StreamSubscription _mouseDownSubscription;
  StreamSubscription _mouseMoveSubscription;
  StreamSubscription _mouseUpSubscription;
  StreamSubscription _mouseWheelSubscription;

  void attach(Camera camera, html.Element element) {
    detach();
    camera.controller = this;
    _contextMenuSubscription = element.onContextMenu.listen((e) => e.preventDefault());
    _mouseDownSubscription = element.onMouseDown.listen(_onMouseDown);
    _mouseWheelSubscription = element.onMouseWheel.listen(_onMouseWheel);

    this.object = camera;
    this.element = element;
  }

  void detach() {
    if (object != null) object.controller = null;
    if (_contextMenuSubscription != null) _contextMenuSubscription.cancel();
    if (_mouseDownSubscription != null) _mouseDownSubscription.cancel();
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
    if (_mouseWheelSubscription != null) _mouseWheelSubscription.cancel();
  }

  void rotateLeft([num angle]) {
    if (angle == null) angle = autoRotationAngle;
    _thetaDelta -= angle;
  }

  void rotateRight([num angle]) {
    if (angle == null) angle = autoRotationAngle;
    _thetaDelta += angle;
  }

  void rotateUp([num angle]) {
    if (angle == null) angle = autoRotationAngle;
    _phiDelta -= angle;
  }

  void rotateDown([num angle]) {
    if (angle == null) angle = autoRotationAngle;
    _phiDelta += angle;
  }

  void zoomIn([num scale]) {
    if (scale == null) scale = zoomScale;
    _scale /= zoomScale;
  }

  void zoomOut([num scale]) {
    if (scale == null) scale = zoomScale;
    _scale *= zoomScale;
  }

  void update() {
    var position = object.position;
    var offset = position - center;
    // angle from z-axis around y-axis
    var theta = math.atan2(offset.x, offset.z);
    // angle from y-axis
    var phi = math.atan2(math.sqrt(offset.x * offset.x + offset.z * offset.z), offset.y);
    if (autoRotate) {
      rotateLeft(autoRotationAngle);
    }
    theta += _thetaDelta;
    phi += _phiDelta;
    phi = math.max(minPolarAngle, math.min(maxPolarAngle, phi));
    phi = math.max(_EPS, math.min(math.PI - _EPS, phi));

    var radius = offset.length * _scale;
    radius = math.max(minDistance, math.min(maxDistance, radius));

    offset.x = radius * math.sin(phi) * math.sin(theta);
    offset.y = radius * math.cos(phi);
    offset.z = radius * math.sin(phi) * math.cos(theta);

    center.copyInto(position);
    object.position = position + offset;
    object.lookAt(center);

    _thetaDelta = 0.0;
    _phiDelta = 0.0;
    _scale = 1.0;

    if (_lastPosition.distanceTo(object.position) > 0) {
      // dispatch changed event ?
      object.position.copyInto(_lastPosition);
    }
  }

  double get autoRotationAngle => 2 * math.PI / 60 / 60 * autoRotateSpeed;
  double get zoomScale => math.pow(0.95, userZoomSpeed);

  void _onMouseDown(html.MouseEvent e) {
    if (!userRotate) return;
    e.preventDefault();
    if (e.button == 0 || e.button == 2) {
      _state = STATE_ROTATE;
      _rotateStart.setValues(e.client.x.toDouble(), e.client.y.toDouble());
    } else if (e.button == 1) {
      _state = STATE_ZOOM;
      _zoomStart.setValues(e.client.x.toDouble(), e.client.y.toDouble());
    }
    _mouseMoveSubscription = html.document.onMouseMove.listen(_onMouseMove);
    _mouseUpSubscription = html.document.onMouseUp.listen(_onMouseUp);
  }

  void _onMouseMove(html.MouseEvent e) {
    e.preventDefault();
    if (_state == STATE_ROTATE) {
      _rotateEnd.setValues(e.client.x.toDouble(), e.client.y.toDouble());
      _rotateDelta = _rotateEnd - _rotateStart;
      rotateLeft(2 * math.PI * _rotateDelta.x / _PIXELS_PER_ROUND * userRotateSpeed);
      rotateUp(2 * math.PI * _rotateDelta.y / _PIXELS_PER_ROUND * userRotateSpeed);
      _rotateEnd.copyInto(_rotateStart);
    } else if (_state == STATE_ZOOM) {
      _zoomEnd.setValues(e.client.x.toDouble(), e.client.y.toDouble());
      _zoomDelta = _zoomEnd - _zoomStart;
      if (_zoomDelta.y > 0) {
        zoomIn();
      } else {
        zoomOut();
      }
      _zoomEnd.copyInto(_zoomStart);
    }
  }

  void _onMouseUp(html.MouseEvent e) {
    if (!userRotate) return;
    if (_mouseMoveSubscription != null) _mouseMoveSubscription.cancel();
    if (_mouseUpSubscription != null) _mouseUpSubscription.cancel();
  }

  void _onMouseWheel(html.WheelEvent e) {
    if (!userZoom) return;
    var delta = e.wheelDeltaY;
    if (delta > 0) zoomOut(); else zoomIn();
  }

}




















