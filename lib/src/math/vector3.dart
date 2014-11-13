// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;




class Vector3 {
  final Float32List _elements;

  Vector3(double x, double y, double z) : _elements = new Float32List(3) {
    setValues(x, y, z);
  }

  Vector3.zero() : _elements = new Float32List(3);

  Vector3.all(double d) : this(d, d, d);

  void setValues(double x, double y, double z) {
    _elements[0] = x;
    _elements[1] = y;
    _elements[2] = z;
  }

  double dot(Vector3 other) {
    double sum;
    sum = _elements[0] * other._elements[0];
    sum += _elements[1] * other._elements[1];
    sum += _elements[2] * other._elements[2];
    return sum;
  }

  Vector3 cross(Vector3 other) {
    double _x = _elements[0];
    double _y = _elements[1];
    double _z = _elements[2];
    double ox = other._elements[0];
    double oy = other._elements[1];
    double oz = other._elements[2];
    return new Vector3(_y * oz - _z * oy, _z * ox - _x * oz, _x * oy - _y * ox);
  }

  Vector3 crossInto(Vector3 other, Vector3 out) {
    double _x = _elements[0];
    double _y = _elements[1];
    double _z = _elements[2];
    double ox = other._elements[0];
    double oy = other._elements[1];
    double oz = other._elements[2];
    out._elements[0] = _y * oz - _z * oy;
    out._elements[1] = _z * ox - _x * oz;
    out._elements[2] = _x * oy - _y * ox;
    return out;
  }

  Vector3 normalize() {
    double l = length;
    if (l == 0.0) {
      return this;
    }
    l = 1.0 / l;
    _elements[0] *= l;
    _elements[1] *= l;
    _elements[2] *= l;
    return this;
  }

  double get length {
    double sum;
    sum = (_elements[0] * _elements[0]);
    sum += (_elements[1] * _elements[1]);
    sum += (_elements[2] * _elements[2]);
    return Math.sqrt(sum);
  }

  /**
   * Length squared.
   */
  double get length2 {
    double sum;
    sum = (_elements[0] * _elements[0]);
    sum += (_elements[1] * _elements[1]);
    sum += (_elements[2] * _elements[2]);
    return sum;
  }

  double operator [](int i) => _elements[i];

  void operator []=(int i, double v) {
    _elements[i] = v;
  }

  Vector3 operator -() => new Vector3(-_elements[0], -_elements[1], -_elements[2]);

  Vector3 operator -(Vector3 other) => new Vector3(_elements[0] - other._elements[0], _elements[1] - other._elements[1], _elements[2] - other._elements[2]);

  Vector3 operator +(Vector3 other) => new Vector3(_elements[0] + other._elements[0], _elements[1] + other._elements[1], _elements[2] + other._elements[2]);

  Vector3 operator /(double scale) {
    var o = 1.0 / scale;
    return new Vector3(_elements[0] * o, _elements[1] * o, _elements[2] * o);
  }

  Vector3 operator *(double scale) {
    var o = scale;
    return new Vector3(_elements[0] * o, _elements[1] * o, _elements[2] * o);
  }

  double get x => _elements[0];
  void set x(num val) {
    _elements[0] = val.toDouble();
  }

  double get y => _elements[1];
  void set y(num val) {
    _elements[1] = val.toDouble();
  }

  double get z => _elements[2];
  void set z(num val) {
    _elements[2] = val.toDouble();
  }

  void copyFrom(Vector3 target) {
    for (var i = 0; i < 3; i++) {
      _elements[i] = target._elements[i];
    }
  }

  Vector3 add(Vector3 other) {
    _elements[0] = _elements[0] + other._elements[0];
    _elements[1] = _elements[1] + other._elements[1];
    _elements[2] = _elements[2] + other._elements[2];
    return this;
  }

  Vector3 clone() => new Vector3(_elements[0], _elements[1], _elements[2]);

  String toString() => '[${_elements[0]},${_elements[1]},${_elements[2]}]';
}
