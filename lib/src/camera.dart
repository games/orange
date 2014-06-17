part of orange;



class Camera {
  Matrix4 _viewMatrix = new Matrix4.identity();
  bool _dirty = true;
  Vector3 _position;

  Vector3 get position => _position;
  set position(Vector3 val) {
    _position = val;
    _dirty = true;
  }

  Matrix4 get viewMatrix {
    return _viewMatrix;
  }

  update(double interval) {}
}

class PerspectiveCamera extends Node {

  double near;
  double far;
  double fov;
  double aspect;
  Matrix4 projectionMatrix;
  Matrix4 _viewMatrix;

  PerspectiveCamera(double aspect, {this.near: 1.0, this.far: 1000.0, this.fov: 45.0}) {
    this.aspect = aspect;
    _viewMatrix = new Matrix4.identity();
    updateProjection();
  }

  lookAt(Vector3 target) {
    _viewMatrix.lookAt(position, target, Axis.Y);
    rotation.setFromRotation(viewMatrix);
    //    viewMatrix.decompose(position, rotation);
  }

  update(double interval) {

  }

  updateProjection() {
    projectionMatrix = new Matrix4.perspective(radians(fov), aspect, near, far);
  }

  Matrix4 get viewProjectionMatrix => projectionMatrix * viewMatrix;
  Matrix4 get viewMatrix => _viewMatrix;

  //  updateMatrix() {
  //    super.updateMatrix();
  //    viewMatrix = worldMatrix.clone();
  //    viewMatrix.invert();
  //  }
}


class ModelCamera extends Camera {
  bool _moving = false;
  html.Point<double> _lastPos;
  double _distance = 32.0;
  Vector3 _center = new Vector3.zero();

  double orbitX = 0.0;
  double orbitY = 0.0;

  ModelCamera(html.CanvasElement canvas) {
    _lastPos = new html.Point<double>(0.0, 0.0);
    canvas.onMouseDown.listen((e) {
      if (e.which == 1) {
        _moving = true;
      }
      _lastPos = e.page;
    });

    canvas.onMouseMove.listen((e) {
      if (_moving) {
        var delta = e.page - _lastPos;
        _lastPos = e.page;

        orbitY += delta.x * 0.025;
        while (orbitY < 0) {
          orbitY += math.PI * 2;
        }
        while (orbitY > math.PI * 2) {
          orbitY -= math.PI * 2;
        }

        orbitX += delta.y * 0.025;
        while (orbitX < 0) {
          orbitX += math.PI * 2;
        }
        while (orbitX >= math.PI * 2) {
          orbitX -= math.PI * 2;
        }
        _dirty = true;
      }
    });

    canvas.onMouseUp.listen((e) => _moving = false);
  }

  Vector3 get center => _center;
  set center(Vector3 val) {
    _center = val;
    _dirty = true;
  }

  double get distance => _distance;
  set distance(double val) {
    _distance = val;
    _dirty = true;
  }

  Matrix4 get viewMatrix {
    if (_dirty) {
      _viewMatrix
          ..setIdentity()
          ..translate(new Vector3(0.0, 0.0, -_distance))
          ..rotateX(orbitX + math.PI / 2)
          ..translate(_center)
          ..rotateX(-math.PI / 2)
          ..rotateY(orbitY);
    }
    return _viewMatrix;
  }
}

class FlyingCamera extends Camera {
  bool _moving = false;
  html.Point<double> _lastPos = new html.Point(0.0, 0.0);
  Vector3 _angles = new Vector3.zero();
  double speed = 25.0;
  List<bool> _pressedKeys = new List.filled(128, false);
  Matrix4 _viewMatrix = new Matrix4.identity();
  Matrix4 _rotMatrix = new Matrix4.identity();

  FlyingCamera(html.CanvasElement canvas) {
    html.window.onKeyDown.listen((e) => _pressedKeys[e.keyCode] = true);
    html.window.onKeyUp.listen((e) => _pressedKeys[e.keyCode] = false);
    canvas.onMouseDown.listen((e) {
      if (e.which == 1) {
        _moving = true;
      }
      _lastPos = e.page;
    });

    canvas.onMouseMove.listen((e) {
      if (_moving) {
        var delta = e.page - _lastPos;
        _lastPos = e.page;
        _angles[1] += delta.x * 0.025;
        while (_angles[1] < 0) {
          _angles[1] += math.PI * 2;
        }
        while (_angles[1] >= math.PI * 2) {
          _angles[1] -= math.PI * 2;
        }
        _angles[0] += delta.y * 0.025;
        if (_angles[0] < -math.PI * 0.5) {
          _angles[0] = -math.PI * 0.5;
        }
        if (_angles[0] > math.PI * 0.5) {
          _angles[0] = math.PI * 0.5;
        }

        _rotMatrix
            ..setIdentity()
            ..rotateY(-_angles[1])
            ..rotateX(-_angles[0]);

        _dirty = true;
      }
    });

    canvas.onMouseUp.listen((e) => _moving = false);
  }

  Vector3 get angles => _angles;
  set angles(Vector3 val) {
    _angles = val;
    _dirty = true;
  }

  Matrix4 get viewMatrix {
    if (_dirty) {
      _viewMatrix
          ..setIdentity()
          ..rotateX(_angles[0])
          ..rotateY(_angles[1])
          ..rotateZ(_angles[2])
          ..translate(new Vector3(-_position[0], -_position[1], -_position[2]));
      _dirty = false;
    }
    return _viewMatrix;
  }

  update(double interval) {
    var dir = new Vector3.zero();
    var speed = (this.speed / 1000) * interval;
    if (_pressedKeys[html.KeyCode.W]) {
      dir[2] -= speed;
    }
    if (_pressedKeys[html.KeyCode.S]) {
      dir[2] += speed;
    }
    if (_pressedKeys[html.KeyCode.A]) {
      dir[0] -= speed;
    }
    if (_pressedKeys[html.KeyCode.D]) {
      dir[0] += speed;
    }
    if (_pressedKeys[html.KeyCode.SPACE]) {
      dir[1] += speed;
    }
    if (_pressedKeys[html.KeyCode.CTRL]) {
      dir[1] -= speed;
    }
    if (dir[0] != 0 || dir[1] != 0 || dir[2] != 0) {
      dir = _rotMatrix.multiplyVector3(dir);
      _position = _position + dir;
      _dirty = true;
    }
  }
}





