/*
  Orange : Simplified BSD License

  Copyright (c) 2014, Valor Zhong
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
  following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
     disclaimer.
    
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
     following disclaimer in the documentation and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
 */

part of orange;




class Vector3 {
  final Float32List _elements;

  Vector3(double x, double y, double z) : _elements = new Float32List(3) {
    setValues(x, y, z);
  }

  Vector3.zero() : _elements = new Float32List(3);

  Vector3.all(double d) : this(d, d, d);

  /// Performs a linear interpolation between two vec3's
  Vector3.lerp(Vector3 a, Vector3 b, double t) : _elements = new Float32List(3) {
    var ax = a[0],
        ay = a[1],
        az = a[2];
    _elements[0] = ax + t * (b[0] - ax);
    _elements[1] = ay + t * (b[1] - ay);
    _elements[2] = az + t * (b[2] - az);
  }

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

  Vector3 operator -(Vector3 other) =>
      new Vector3(_elements[0] - other._elements[0], _elements[1] - other._elements[1], _elements[2] - other._elements[2]);

  Vector3 operator +(Vector3 other) =>
      new Vector3(_elements[0] + other._elements[0], _elements[1] + other._elements[1], _elements[2] + other._elements[2]);

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

  static final Vector3 forward = new Vector3(0.0, 0.0, 1.0);
  static final Vector3 back = new Vector3(0.0, 0.0, -1.0);
  static final Vector3 left = new Vector3(-1.0, 0.0, 0.0);
  static final Vector3 right = new Vector3(1.0, 0.0, 0.0);
  static final Vector3 up = new Vector3(0.0, 1.0, 0.0);
  static final Vector3 down = new Vector3(0.0, -1.0, 0.0);
}
