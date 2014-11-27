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

  Vector4.all(double d) : this(d, d, d, d);

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

  Vector4 sub(Vector4 other) {
    _elements[0] = _elements[0] - other._elements[0];
    _elements[1] = _elements[1] - other._elements[1];
    _elements[2] = _elements[2] - other._elements[2];
    _elements[3] = _elements[3] - other._elements[3];
    return this;
  }

  Vector4 operator *(Vector4 other) {
    return new Vector4(_elements[0] * other.x, _elements[1] * other.y, _elements[2] * other.z, _elements[3] * other.w);
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

  void copyFrom(Vector4 src) {
    _elements[0] = src._elements[0];
    _elements[1] = src._elements[1];
    _elements[2] = src._elements[2];
    _elements[3] = src._elements[3];
  }

  Vector4 clone() => new Vector4(_elements[0], _elements[1], _elements[2], _elements[3]);

  String toString() => '[${_elements[0]},${_elements[1]},${_elements[2]},${_elements[3]}]';


}
