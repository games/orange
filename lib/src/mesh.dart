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



class Mesh extends Disposable {

  VertexBuffer vertexBuffer;
  VertexBuffer normalBuffer;
  VertexBuffer texCoordsBuffer;
  VertexBuffer texCoords2Buffer;
  VertexBuffer indexBuffer;
  
  void set vertices(List<double> data) {
    vertexBuffer = new VertexBuffer.vertexData(new Float32List.fromList(data), 3);
  }
  
  void set indices(List<int> data) {
    indexBuffer = new VertexBuffer.indexData(new Uint16List.fromList(data));
  }
  
  void set normals(List<double> data) {
    normalBuffer = new VertexBuffer.vertexData(new Float32List.fromList(data), 3);
  }
  
  void set texCoords(List<double> data) {
    texCoordsBuffer = new VertexBuffer.vertexData(new Float32List.fromList(data), 2);
  }
  
  void set texCoords2(List<double> data) {
    texCoords2Buffer = new VertexBuffer.vertexData(new Float32List.fromList(data), 2);
  }

  void computeNormals() {
    // TODO
  }

  void computeTangentSpace([bool normals]) {
    // TODO
  }

  Mesh clone() {
    var mesh = new Mesh();
    // TODO
    return mesh;
  }

  @override
  void dispose() {
    _deleteBuffer(vertexBuffer);
    _deleteBuffer(indexBuffer);
    _deleteBuffer(normalBuffer);
    _deleteBuffer(texCoordsBuffer);
    _deleteBuffer(texCoords2Buffer);
  }
  
  void _deleteBuffer(VertexBuffer vertexBuffer) {
    if(vertexBuffer != null) vertexBuffer.dispose();
    vertexBuffer = null;
  }
}
