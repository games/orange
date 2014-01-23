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
  
  generateFacesNormals() {
    var vertexCount = geometry.buffers[Semantics.position].count;
    _normals = new Float32List(_vertices.length);
    geometry.buffers[Semantics.normal] = new BufferView(3, gl.FLOAT, 0, 0, count: vertexCount, data: _normals);
    
    var normals = new List<Vector3>();
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
      
      normals.add(getNormal(i) + normal);
    }
    for(var i = 0; i < normals.length; i++) {
      setNormal(i, normals[i].normalize());
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
  
  applyTransform(Matrix4 matrix) {
    var len = _vertices.length ~/ 3;
    for (var i = 0; i < len; i++) {
      setVertex(i, matrix * getVertex(i));
    }

    var inverseTransposeMatrix = matrix.clone();
    inverseTransposeMatrix.invert();
    inverseTransposeMatrix.transpose();
    len = _normals.length ~/ 3;
    for (var i = 0; i < len; i++) {
      setNormal(i, inverseTransposeMatrix * getNormal(i));
    }
  }

  int get vertexesCount => geometry.buffers[Semantics.position].count;
}




















