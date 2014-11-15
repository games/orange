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



class VertexAttribute {
  /// index of vertex atribute
  int location;
  /// size is number of components per attribute
  int size;
  /// type specifies the data type of the values stored in the array
  int type;
  /// The normalized parameter in the VertexAttribPointer command identifies 
  /// whether integer types should be normalized when converted to floating-point.
  bool normalized;
  /// Specifies the offset in bytes between the beginning of consecutive vertex attributes. 
  /// Default value is 0, maximum is 255. Must be a multiple of type.
  int stride;
  /// Specifies an offset in bytes of the first component of the first vertex attribute in the array. 
  /// Default is 0 which means that vertex attributes are tightly packed. Must be a multiple of type.
  int offset;

  VertexAttribute(this.size, this.type, this.normalized, this.stride, this.offset);
}

class VertexBuffer extends Disposable {
  gl.Buffer _bufferHandle;
  TypedData _data;

  int _target;
  int _usage = gl.STATIC_DRAW;
  
  bool _ready = false;
  bool get ready => _ready;

  // TODO one vertex buffer maybe have multi-attributes.
  VertexAttribute _attribute;

  int _numVertices = 0;
  int get numVertices => _numVertices;
  int get lengthInBytes => _data == null ? 0 : _data.lengthInBytes;

  VertexBuffer.vertexData(Float32List data, int vertexSize) {
    _target = gl.ARRAY_BUFFER;
    _numVertices = data.length ~/ vertexSize;
    _data = data;
    _attribute = new VertexAttribute(vertexSize, gl.FLOAT, false, 0, 0);
  }

  VertexBuffer.indexData(Uint16List data) {
    _target = gl.ELEMENT_ARRAY_BUFFER;
    _numVertices = data.length ~/ 3;
    _data = data;
    _attribute = new VertexAttribute(3, gl.UNSIGNED_SHORT, false, 0, 0);
  }

  void upload(GraphicsDevice graphicsDevice) {
    if (_bufferHandle == null) {
      _bufferHandle = graphicsDevice.createBuffer();
    }
    graphicsDevice.uploaderBufferData(this);
    _ready = true;
  }

  void enable(GraphicsDevice graphicsDevice, EffectParameter parameter) {
    graphicsDevice.enableBuffer(parameter.location, this);
  }

  @override
  void dispose() {
    if (_bufferHandle != null) {
      Orange.instance.graphicsDevice.deleteBuffer(this);
    }
    _ready = false;
    _bufferHandle = null;
    _data = null;
  }
}