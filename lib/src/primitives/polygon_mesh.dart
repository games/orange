part of orange;



class PolygonMesh extends Mesh {
  
  Float32List _vertexes;
  Float32List _normals;
  Float32List _texCoords;
  Uint16List _indices;
  
  initialzie(int vertexCount, int facesCount) {
    geometry = new Geometry();
    geometry.vertexCount = vertexCount;
    _vertexes = new Float32List(vertexCount * 3);
    geometry.buffers[Semantics.position] = new BufferView(3, gl.FLOAT, 0, 0, count: vertexCount, data: _vertexes);
    _normals = new Float32List(vertexCount * 3);
    geometry.buffers[Semantics.normal] = new BufferView(3, gl.FLOAT, 0, 0, count: vertexCount, data: _normals);
    _texCoords = new Float32List(vertexCount * 2);
    geometry.buffers[Semantics.texture] = new BufferView(2, gl.FLOAT, 0, 0, count: vertexCount, data: _texCoords);
    _indices = new Uint16List(facesCount);
    faces = new BufferView(0, gl.UNSIGNED_SHORT, 0, 0, count: facesCount, data: _indices, target: gl.ELEMENT_ARRAY_BUFFER);
  }
  
  setVertexes(List vertexes) {
    _vertexes = new Float32List.fromList(vertexes);
    geometry.buffers[Semantics.position] = new BufferView(3, gl.FLOAT, 0, 0, count: _vertexes.length ~/ 3, data: _vertexes);
  }
  
  setNormals(List normals) {
    _normals = new Float32List.fromList(normals);
    geometry.buffers[Semantics.normal] = new BufferView(3, gl.FLOAT, 0, 0, count: _normals.length ~/3, data: _normals);
  }
  
  setTexCoords(List texCoords) {
    _texCoords = new Float32List.fromList(texCoords);
    geometry.buffers[Semantics.texture] = new BufferView(2, gl.FLOAT, 0, 0, count: _texCoords.length ~/ 2, data: _texCoords);
  }
  
  setFaces(List indices) {
    _indices = new Uint16List.fromList(indices);
    faces = new BufferView(0, gl.UNSIGNED_SHORT, 0, 0, count: _indices.length, data: _indices, target: gl.ELEMENT_ARRAY_BUFFER);
  }
  
  calculateNormals() {
    var vertexCount = geometry.buffers[Semantics.position].count;
    _normals.fillRange(0, 0);

    for(var i = 0; i < vertexCount; i++) {
      var i1 = _indices[i];
      var i2 = _indices[i + 1];
      var i3 = _indices[i + 2];
      
      var p1 = getVertex(i1);
      var p2 = getVertex(i2);
      var p3 = getVertex(i3);
      
      var v1 = p1 - p2;
      var v2 = p2 - p3;
      var normal = v1.cross(v2);
      
      setNormal(i1, getNormal(i1) + normal);
      setNormal(i2, getNormal(i2) + normal);
      setNormal(i3, getNormal(i3) + normal);
    }
    
    for(var i = 0; i < faces.count; i++) {
      var index = _indices[i];
      setNormal(index, getNormal(index).normalize());
    }
  }
  
  Vector3 getVertex(int index) {
    index *= 3;
    return new Vector3(_vertexes[index], _vertexes[index + 1], _vertexes[index + 2]);
  }
  setVertex(int index, List vertex) {
    index *= 3;
    _vertexes[index] = vertex[0];
    _vertexes[index + 1] = vertex[1];
    _vertexes[index + 2] = vertex[2];
  }
  
  Vector3 getNormal(int index) {
    index *= 3;
    return new Vector3(_normals[index], _normals[index + 1], _normals[index + 2]);
  }
  setNormal(int index, Vector3 normal) {
    index *= 3;
    _normals[index] = normal.x;
    _normals[index + 1] = normal.y;
    _normals[index + 2] = normal.z;
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
  
}




















