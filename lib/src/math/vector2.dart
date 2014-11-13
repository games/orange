// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;




class Vector2 {
  final Float32List _elements;

  Vector2(double x, double y) : _elements = new Float32List(2) {
    setValues(x, y);
  }

  Vector2.zero() : _elements = new Float32List(2);

  Vector2.all(double d) : this(d, d);

  void setValues(double x, double y) {
    _elements[0] = x;
    _elements[1] = y;
  }

  double operator [](int i) => _elements[i];

  void operator []=(int i, double v) {
    _elements[i] = v;
  }

  Vector2 operator -() => new Vector2(-_elements[0], -_elements[1]);

  Vector2 operator -(Vector2 other) => new Vector2(_elements[0] - other._elements[0], _elements[1] - other._elements[1]);

  Vector2 operator +(Vector2 other) => new Vector2(_elements[0] + other._elements[0], _elements[1] + other._elements[1]);

  Vector2 operator /(double scale) {
    var o = 1.0 / scale;
    return new Vector2(_elements[0] * o, _elements[1] * o);
  }

  Vector2 operator *(double scale) {
    var o = scale;
    return new Vector2(_elements[0] * o, _elements[1] * o);
  }

  double get x => _elements[0];
  void set x(num val) {
    _elements[0] = val.toDouble();
  }

  double get y => _elements[1];
  void set y(num val) {
    _elements[1] = val.toDouble();
  }
  
  Vector2 clone() => new Vector2(_elements[0], _elements[1]);

  String toString() => '[${_elements[0]},${_elements[1]}}]';
}
