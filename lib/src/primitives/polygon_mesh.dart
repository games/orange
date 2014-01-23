part of orange;



class PolygonMesh extends Mesh {
  
  Float32List _vertices;
  Float32List _normals;
  Float32List _texCoords;
  Uint16List _indices;
  
  PolygonMesh() {
    geometry = new Geometry();
  }
  
  setVertices(List vertices) {
    _vertices = new Float32List.fromList(vertices);
    geometry.buffers[Semantics.position] = new BufferView(3, gl.FLOAT, 0, 0, count: _vertices.length ~/ 3, data: _vertices);
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
  
  calculateSurfaceNormals() {
    _normals = new Float32List(_vertices.length);
    geometry.buffers[Semantics.normal] = new BufferView(3, gl.FLOAT, 0, 0, count: _vertices.length ~/ 3, data: _normals);
    
    var count = _indices.length;
    for(var f = 0; f < count; f += 3) {
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

  int get vertexesCount => geometry.buffers[Semantics.position].count;
}




















