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



class Texture implements Disposable {

  gl.Texture _texture;
  String id;
  int width;
  int height;
  bool mipMapping = false;
  bool flip = false;
  String source;

  /// gl.TEXTURE_2D or gl.TEXTURE_CUBE_MAP
  int target;

  /// gl.RGBA
  int format;

  int type = gl.UNSIGNED_BYTE;

  Sampler sampler = Sampler.defaultSampler;

  Texture._(this.id);

  bool _ready = false;
  bool get ready => _ready;

  Vector2 _cachedOffset;
  Vector2 _cachedScale;
  Vector3 _cachedAng;
  Vector4 _t0, _t1, _t2;
  Matrix4 _cachedMatrix;
  Matrix4 _rowGenerationMatrix;

  Vector2 offset = new Vector2.all(0.0);
  Vector2 scale = new Vector2.all(1.0);
  /// x: yaw, y: pitch, z: roll
  Vector3 angle = new Vector3.all(0.0);

  /// from BabylonJS
  Matrix4 get matrix {
    if (_cachedMatrix != null &&
        offset.equals(_cachedOffset) &&
        scale.equals(_cachedScale) &&
        angle.equals(_cachedAng)) {
      return _cachedMatrix;
    }
    _cachedOffset = offset;
    _cachedScale = scale;
    _cachedAng = angle;

    if (_cachedMatrix == null) {
      _cachedMatrix = new Matrix4.zero();
      _rowGenerationMatrix = new Matrix4.identity();
      _t0 = new Vector4.zero();
      _t1 = new Vector4.zero();
      _t2 = new Vector4.zero();
    }
    _rowGenerationMatrix.fromQuaternion(new Quaternion.yawPitchRoll(angle.x, angle.y, angle.z));
    _prepareRowForTextureGeneration(0.0, 0.0, 0.0, _t0);
    _prepareRowForTextureGeneration(1.0, 0.0, 0.0, _t1);
    _prepareRowForTextureGeneration(0.0, 1.0, 0.0, _t2);
    _t1.sub(_t0);
    _t2.sub(_t0);
    _cachedMatrix.setIdentity();
    _cachedMatrix.setColumn(0, _t1);
    _cachedMatrix.setColumn(1, _t2);
    _cachedMatrix.setColumn(2, _t0);
    return _cachedMatrix;
  }

  void _prepareRowForTextureGeneration(double x, double y, double z, Vector4 t) {
    x -= offset.x + 0.5;
    y -= offset.y + 0.5;
    z -= 0.5;
    Vector4 t1 = _rowGenerationMatrix * new Vector4(x, y, z, 0.0);
    t1.x *= scale.x;
    t1.y *= scale.y;
    t1.x += 0.5;
    t1.y += 0.5;
    t1.z += 0.5;
    t.copyFrom(t1);
  }

  @override
  void dispose() {
    if (_texture != null) {
      Orange.instance.graphicsDevice.deleteTexture(_texture);
    }
  }
}

















