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



class Color3 extends Vector3 {
  Color3.all(double d) : super.all(d);
  Color3(double x, double y, double z) : super(x, y, z);
  Color3.zero() : super.zero();
}

class Color4 extends Vector4 {
  Color4.all(double d) : super.all(d);
  Color4.fromList(List<num> list) : super.fromList(list);
  Color4(double r, double g, double b, double a) : super(r, g, b, a);
  Color4.zero() : super.zero();

  Color4 scale(double s) {
    _elements[0] *= s;
    _elements[1] *= s;
    _elements[2] *= s;
    return this;
  }
  
  set hexColor(num hexColor) {
    var h = hexColor.floor().toInt();
    _elements[0] = ((h & 0xFF0000) >> 16) / 255;
    _elements[1] = ((h & 0x00FF00) >> 8) / 255;
    _elements[2] = (h & 0x0000FF) / 255;
    _elements[3] = 1.0;
  }

  set red(double val) => _elements[0] = val;
  set green(double val) => _elements[1] = val;
  set blue(double val) => _elements[2] = val;
  set alpha(double val) => _elements[3] = val;
  double get red => _elements[0];
  double get green => _elements[1];
  double get blue => _elements[2];
  double get alpha => _elements[3];
  
  String toString() => 'R:${_elements[0]},G:${_elements[1]},B:${_elements[2]},A:${_elements[3]}';

  static Color4 white() => new Color4(1.0, 1.0, 1.0, 1.0);
  static Color4 black() => new Color4(0.0, 0.0, 0.0, 1.0);
}
