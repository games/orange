// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;



class Transform extends Component {

  Vector3 _position;
  Vector3 _scale;
  Quaternion _rotation;
  Matrix4 _localMatrix;
  bool _dirty;

  Vector3 get scale => _scale;

  void set scale(Vector3 val) {
    _scale.copyFrom(val);
    _dirty = true;
  }

  Quaternion get rotation => _rotation;

  void set rotation(Quaternion val) {
    _rotation.copyFrom(val);
    _dirty = true;
  }

  Vector3 get position => _position;

  void set position(Vector3 val) {
    _position.copyFrom(val);
    _dirty = true;
  }

  void translate(dynamic x, [double y = 0.0, double z = 0.0]) {
    if (x is Vector3) {
      _position.add(x);
    } else {
      _position.x += x;
      _position.y += y;
      _position.z += z;
    }
    _dirty = true;
  }
  
  void rotateX(double rad) {
    _rotation.rotateX(rad);
    _dirty = true;
  }

  void rotateY(double rad) {
    _rotation.rotateY(rad);
    _dirty = true;
  }

  void rotateZ(double rad) {
    _rotation.rotateZ(rad);
    _dirty = true;
  }

  applyMatrix(Matrix4 m) {
    _localMatrix.copyForm(m);
    _localMatrix.decompose(_position, _rotation, _scale);
    _dirty = false;
  }

  @override
  void start() {
    _position = new Vector3.zero();
    _scale = new Vector3.all(1.0);
    _rotation = new Quaternion.identity();
    _localMatrix = new Matrix4.identity();
    _dirty = true;
  }

  @override
  void update(GameTime time) {
    if(_dirty) {
      _dirty = false;
      _localMatrix.recompose(_position, _rotation, _scale);
    }
    if(_target.parent != null) {
      
    }
  }
}







