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




class Color {

  final Float32List _elements;

  Color.zero() : _elements = new Float32List(4);

  Color(double r, double g, double b, [double alpha = 1.0]) : _elements = new Float32List(4) {
    setValues(r, g, b, alpha);
  }

  Color.fromHex(num hex) : _elements = new Float32List(4) {
    hexColor = hex;
  }

  Color.fromList(List<num> list) : _elements = new Float32List(4) {
    _elements[3] = 1.0;
    for (var i = 0; i < list.length && i < 4; i++) {
      _elements[i] = list[i].toDouble();
    }
  }

  Color setValues(double r, double g, double b, double alpha) {
    _elements[0] = r;
    _elements[1] = g;
    _elements[2] = b;
    _elements[3] = alpha;
    return this;
  }

  Color scale(double s) {
    _elements[0] *= s;
    _elements[1] *= s;
    _elements[2] *= s;
    return this;
  }

  Color operator *(Color other) {
    return new Color(_elements[0] * other.red, _elements[1] * other.green, _elements[2] * other.blue, _elements[3] * other.alpha);
  }
  
  set hexColor(num hexColor) {
    var h = hexColor.floor().toInt();
    _elements[0] = ((h & 0xFF0000) >> 16) / 255;
    _elements[1] = ((h & 0x00FF00) >> 8) / 255;
    _elements[2] = (h & 0x0000FF) / 255;
    _elements[3] = 1.0;
  }

  void set red(double val) {
    _elements[0] = val;
  }

  void set green(double val) {
    _elements[1] = val;
  }

  void set blue(double val) {
    _elements[2] = val;
  }

  void set alpha(double val) {
    _elements[3] = val;
  }

  Color clone() {
    return new Color(_elements[0], _elements[1], _elements[2], _elements[3]);
  }

  double get red => _elements[0];
  double get green => _elements[1];
  double get blue => _elements[2];
  double get alpha => _elements[3];
  
  String toString() => 'R:${_elements[0]},G:${_elements[1]},B:${_elements[2]},A:${_elements[3]}';

  static Color white() => new Color(1.0, 1.0, 1.0);
  static Color black() => new Color(0.0, 0.0, 0.0);
}
