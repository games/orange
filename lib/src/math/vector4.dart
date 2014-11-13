// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of orange;




class Vector4 {
  final Float32List _elements;

  Vector4(double x, double y, double z, double w) : _elements = new Float32List(4) {
    setValues(x, y, z, w);
  }

  Vector4.fromList(List<num> list) : _elements = new Float32List(4) {
    for (var i = 0; i < list.length && i < 4; i++) {
      _elements[i] = list[i].toDouble();
    }
  }

  Vector4.zero() : _elements = new Float32List(4);

  Vector4 setValues(double x, double y, double z, double w) {
    _elements[0] = x;
    _elements[1] = y;
    _elements[2] = z;
    _elements[3] = w;
    return this;
  }
  
  Vector4 scale(double s) {
    _elements[0] *= s;
    _elements[1] *= s;
    _elements[2] *= s;
    _elements[3] *= s;
    return this;
  }

  double operator [](int i) => _elements[i];

  void operator []=(int i, double v) {
    _elements[i] = v;
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

  double get w => _elements[3];
  void set w(num val) {
    _elements[3] = val.toDouble();
  }
  
  Vector4 clone() => new Vector4(_elements[0], _elements[1], _elements[2], _elements[3]);
  
  String toString() => '[${_elements[0]},${_elements[1]},${_elements[2]},${_elements[3]}]';
  
}
