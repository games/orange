// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;


class Quaternion {
  final Float32List _elements;

  Quaternion(double x, double y, double z, double w) : _elements = new Float32List(4) {
    _elements[0] = x;
    _elements[1] = y;
    _elements[2] = z;
    _elements[3] = w;
  }

  Quaternion.identity() : _elements = new Float32List(4) {
    _elements[3] = 1.0;
  }

  Quaternion.random(Math.Random rn) : _elements = new Float32List(4) {
    // From: "Uniform Random Rotations", Ken Shoemake, Graphics Gems III,
    // pg. 124-132.
    double x0 = rn.nextDouble();
    double r1 = Math.sqrt(1.0 - x0);
    double r2 = Math.sqrt(x0);
    double t1 = Math.PI * 2.0 * rn.nextDouble();
    double t2 = Math.PI * 2.0 * rn.nextDouble();
    double c1 = Math.cos(t1);
    double s1 = Math.sin(t1);
    double c2 = Math.cos(t2);
    double s2 = Math.sin(t2);
    _elements[0] = s1 * r1;
    _elements[1] = c1 * r1;
    _elements[2] = s2 * r2;
    _elements[3] = c2 * r2;
  }

  void setIdentity() {
    _elements[0] = 0.0;
    _elements[1] = 0.0;
    _elements[2] = 0.0;
    _elements[3] = 1.0;
  }

  void copyFrom(Quaternion val) {
    _elements[0] = val._elements[0];
    _elements[1] = val._elements[1];
    _elements[2] = val._elements[2];
    _elements[3] = val._elements[3];
  }

  Quaternion setRotationAxis(Vector3 axis, double rad) {
    rad *= 0.5;
    var sin = Math.sin(rad);
    _elements[3] = Math.cos(rad);
    _elements[0] = axis.x * sin;
    _elements[1] = axis.y * sin;
    _elements[2] = axis.z * sin;
    return this;
  }

  Vector3 get axis {
    double scale = 1.0 / (1.0 - (_elements[3] * _elements[3]));
    return new Vector3(_elements[0] * scale, _elements[1] * scale, _elements[2] * scale);
  }

  double get radians => 2.0 * Math.acos(_elements[3]);

  void rotateX(double rad) {
    rad *= 0.5;
    var ax = _elements[0], ay = _elements[1], az = _elements[2], aw = _elements[3], bx = Math.sin(rad), bw = Math.cos(rad);
    _elements[0] = ax * bw + aw * bx;
    _elements[1] = ay * bw + az * bx;
    _elements[2] = az * bw - ay * bx;
    _elements[3] = aw * bw - ax * bx;
  }

  void rotateY(double rad) {
    rad *= 0.5;
    var ax = _elements[0], ay = _elements[1], az = _elements[2], aw = _elements[3], by = Math.sin(rad), bw = Math.cos(rad);
    _elements[0] = ax * bw - az * by;
    _elements[1] = ay * bw + aw * by;
    _elements[2] = az * bw + ax * by;
    _elements[3] = aw * bw - ay * by;
  }

  void rotateZ(double rad) {
    rad *= 0.5;
    var ax = _elements[0], ay = _elements[1], az = _elements[2], aw = _elements[3], bz = Math.sin(rad), bw = Math.cos(rad);
    _elements[0] = ax * bw + ay * bz;
    _elements[1] = ay * bw - ax * bz;
    _elements[2] = az * bw + aw * bz;
    _elements[3] = aw * bw - az * bz;
  }

  /// Rotates [v] by [this].

  Vector3 rotate(Vector3 v) {
    // conjugate(this) * [v,0] * this
    double _w = _elements[3];
    double _z = _elements[2];
    double _y = _elements[1];
    double _x = _elements[0];
    double tiw = _w;
    double tiz = -_z;
    double tiy = -_y;
    double tix = -_x;
    double tx = tiw * v.x + tix * 0.0 + tiy * v.z - tiz * v.y;
    double ty = tiw * v.y + tiy * 0.0 + tiz * v.x - tix * v.z;
    double tz = tiw * v.z + tiz * 0.0 + tix * v.y - tiy * v.x;
    double tw = tiw * 0.0 - tix * v.x - tiy * v.y - tiz * v.z;
    double result_x = tw * _x + tx * _w + ty * _z - tz * _y;
    double result_y = tw * _y + ty * _w + tz * _x - tx * _z;
    double result_z = tw * _z + tz * _w + tx * _y - ty * _x;
    v._elements[2] = result_z;
    v._elements[1] = result_y;
    v._elements[0] = result_x;
    return v;
  }

  void setFromRotation(Matrix4 m) {
    // http://www.euclideanspace.com/Maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
    // assumes the upper 3x3 of m is a pure rotation matrix (i.e, unscaled)
    var te = m._elements, m11 = te[0], m12 = te[4], m13 = te[8], m21 = te[1], m22 = te[5], m23 = te[9], m31 = te[2], m32 = te[6], m33 = te[10], trace = m11 + m22 + m33, s;

    if (trace > 0) {
      s = 0.5 / Math.sqrt(trace + 1.0);
      _elements[3] = 0.25 / s;
      _elements[0] = (m32 - m23) * s;
      _elements[1] = (m13 - m31) * s;
      _elements[2] = (m21 - m12) * s;
    } else if (m11 > m22 && m11 > m33) {
      s = 2.0 * Math.sqrt(1.0 + m11 - m22 - m33);
      _elements[3] = (m32 - m23) / s;
      _elements[0] = 0.25 * s;
      _elements[1] = (m12 + m21) / s;
      _elements[2] = (m13 + m31) / s;

    } else if (m22 > m33) {
      s = 2.0 * Math.sqrt(1.0 + m22 - m11 - m33);
      _elements[3] = (m13 - m31) / s;
      _elements[0] = (m12 + m21) / s;
      _elements[1] = 0.25 * s;
      _elements[2] = (m23 + m32) / s;
    } else {
      s = 2.0 * Math.sqrt(1.0 + m33 - m11 - m22);
      _elements[3] = (m21 - m12) / s;
      _elements[0] = (m13 + m31) / s;
      _elements[1] = (m23 + m32) / s;
      _elements[2] = 0.25 * s;
    }
  }

  Quaternion normalize() {
    double l = length;
    if (l == 0.0) {
      return this;
    }
    l = 1.0 / l;
    _elements[3] = _elements[3] * l;
    _elements[2] = _elements[2] * l;
    _elements[1] = _elements[1] * l;
    _elements[0] = _elements[0] * l;
    return this;
  }

  double get length2 {
    double _x = _elements[0];
    double _y = _elements[1];
    double _z = _elements[2];
    double _w = _elements[3];
    return (_x * _x) + (_y * _y) + (_z * _z) + (_w * _w);
  }

  double get length {
    return Math.sqrt(length2);
  }

  Quaternion clone() {
    return new Quaternion(_elements[0], _elements[1], _elements[2], _elements[3]);
  }

  double operator [](int i) => _elements[i];

  void operator []=(int i, double v) {
    _elements[i] = v;
  }

  String toString() => '[${_elements[0]},${_elements[1]},${_elements[2]},${_elements[3]}]';
}
