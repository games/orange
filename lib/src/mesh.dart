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

  Float32List _vertices;
  Float32List _normals;
  Float32List _texCoords;
  Float32List _texCoords2;
  Float32List _tangents;
  Uint16List _indices;

  VertexBuffer vertexBuffer;
  VertexBuffer normalBuffer;
  VertexBuffer texCoordsBuffer;
  VertexBuffer texCoords2Buffer;
  VertexBuffer indexBuffer;

  void set vertices(List<double> data) {
    _vertices = new Float32List.fromList(data);
    vertexBuffer = new VertexBuffer.vertexData(_vertices, 3);
  }

  void set indices(List<int> data) {
    _indices = new Uint16List.fromList(data);
    indexBuffer = new VertexBuffer.indexData(_indices);
  }

  void set normals(List<double> data) {
    _normals = new Float32List.fromList(data);
    normalBuffer = new VertexBuffer.vertexData(_normals, 3);
  }

  void set texCoords(List<double> data) {
    _texCoords = new Float32List.fromList(data);
    texCoordsBuffer = new VertexBuffer.vertexData(_texCoords, 2);
  }

  void set texCoords2(List<double> data) {
    _texCoords2 = new Float32List.fromList(data);
    texCoords2Buffer = new VertexBuffer.vertexData(_texCoords2, 2);
  }

  void computeNormals() {
    _normals = new Float32List(_vertices.length);
    normalBuffer = new VertexBuffer.vertexData(_normals, 3);

    var count = _indices.length;
    for (var f = 0; f < count; f += 3) {
      var i1 = _indices[f];
      var i2 = _indices[f + 1];
      var i3 = _indices[f + 2];

      var p1 = getVertex(i1);
      var p2 = getVertex(i2);
      var p3 = getVertex(i3);

      var v1 = p2 - p1;
      var v2 = p3 - p1;
      var normal = v1.cross(v2);

      setNormal(i1, getNormal(i1) + normal);
      setNormal(i2, getNormal(i2) + normal);
      setNormal(i3, getNormal(i3) + normal);
    }
  }

  Vector3 getVertex(int index) {
    index *= 3;
    return new Vector3(_vertices[index], _vertices[index + 1], _vertices[index + 2]);
  }

  setVertex(int index, vertex) {
    index *= 3;
    _vertices[index] = vertex[0];
    _vertices[index + 1] = vertex[1];
    _vertices[index + 2] = vertex[2];
  }

  Vector3 getNormal(int index) {
    index *= 3;
    return new Vector3(_normals[index], _normals[index + 1], _normals[index + 2]);
  }

  setNormal(int index, normal) {
    index *= 3;
    _normals[index] = normal[0];
    _normals[index + 1] = normal[1];
    _normals[index + 2] = normal[2];
  }

  Vector2 getTexCoord(int index) {
    index *= 2;
    return new Vector2(_texCoords[index], _texCoords[index + 1]);
  }

  setTexCoord(int index, List uv) {
    index *= 2;
    _texCoords[index] = uv[0];
    _texCoords[index + 1] = uv[1];
  }

  Vector2 getTexCoord2(int index) {
    index *= 2;
    return new Vector2(_texCoords2[index], _texCoords2[index + 1]);
  }

  setTexCoord2(int index, List uv) {
    index *= 2;
    _texCoords2[index] = uv[0];
    _texCoords2[index + 1] = uv[1];
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
    if (vertexBuffer != null) vertexBuffer.dispose();
    vertexBuffer = null;
  }
}
