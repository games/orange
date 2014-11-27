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
  
  bool equals(Vector2 other) {
    if(other == null) return false;
    return x == other.x && y == other.y;
  }
}
