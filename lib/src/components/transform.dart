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



class Transform extends Component {

  Vector3 _position;
  Vector3 _scale;
  Quaternion _rotation;
  Matrix4 _localMatrix;
  Matrix4 _worldMatrix;
  bool _dirty;

  Matrix4 get worldMatrix => _worldMatrix;

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
    if (_dirty) {
      _dirty = false;
      _localMatrix.recompose(_position, _rotation, _scale);
    }
    if (_target.parent != null) {
      _worldMatrix = _target.parent.transform.worldMatrix * _localMatrix;
    } else {
      _worldMatrix = _localMatrix;
    }
  }
}






