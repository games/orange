part of orange;



class PolygonMesh extends Mesh {

  Float32List _positions;
  Float32List _normals;
  Float32List _texCoords;
  Float32List _tangents;
  Uint16List _indices;

  PolygonMesh({String name}) : super(name: name) {
    _geometry = new Geometry();
  }

  setPositions(List positions) {
    _positions = new Float32List.fromList(positions);
    _geometry.positions = _positions;
    _boundingInfo = _geometry.boundingInfo;
  }

  setNormals(List normals) {
    _normals = new Float32List.fromList(normals);
    geometry.normals = _normals;
  }

  setTexCoords(List texCoords) {
    _texCoords = new Float32List.fromList(texCoords);
    geometry.texCoords = _texCoords;
  }

  setIndices(List data) {
    _indices = new Uint16List.fromList(data);
    indices = _indices;
  }

  calculateSurfaceNormals() {
    _normals = new Float32List(_positions.length);
    geometry.buffers[Semantics.normal] = new VertexBuffer(3, gl.FLOAT, 0, 0, count: _positions.length ~/ 3, data: _normals);

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

  // http://www.terathon.com/code/tangent.html
  calculateTangents() {
    _tangents = new Float32List(_positions.length);
    geometry.buffers[Semantics.tangent] = new VertexBuffer(3, gl.FLOAT, 0, 0, count: _positions.length ~/ 3, data: _tangents);
    
    
    var count = _indices.length;
    var tan1 = new List<Vector3>.generate(_positions.length, (i) => new Vector3.zero());
    var tan2 = new List<Vector3>.generate(_positions.length, (i) => new Vector3.zero());
    
    for (var f = 0; f < count; f += 3) {
      var i1 = _indices[f];
      var i2 = _indices[f + 1];
      var i3 = _indices[f + 2];

      var p1 = getVertex(i1);
      var p2 = getVertex(i2);
      var p3 = getVertex(i3);
      
      var w1 = getTexCoord(i1);
      var w2 = getTexCoord(i1);
      var w3 = getTexCoord(i1);

      var v1 = p2 - p1;
      var v2 = p3 - p1;
      
      var s1 = w2 - w1;
      var s2 = w3 - w1;
      
      var r = 1.0 / (s1.x * s2.y - s2.x * s1.y);
      var sdir = new Vector3((s2.y * v1.x - s1.y * v2.x) * r,
                             (s2.y * v1.y - s1.y * v2.y) * r,
                             (s2.y * v1.z - s1.y * v2.z) * r);
      var tdir = new Vector3((s1.x * v2.x - s2.x * v1.x) * r,
                             (s1.x * v2.y - s2.x * v1.y) * r,
                             (s1.x * v2.z - s2.x * v1.z) * r);
      
      tan1[i1] += sdir;
      tan1[i2] += sdir;
      tan1[i3] += sdir;
      
      tan2[i1] += tdir;
      tan2[i2] += tdir;
      tan2[i3] += tdir;
    }
    
    for (var i = 0; i < count; i++) {
      var vi = _indices[i];
      var n = getNormal(vi);
      var t = tan1[vi];
      var tan = (t - n * n.dot(t)).normalized();
      setTangents(vi, tan);
      // TODO Calculate handedness
      //   -> tan.w = (Dot(Cross(n, t), tan2[a]) < 0.0F) ? -1.0F : 1.0F;
    }
  }
  
  Vector3 getTangents(int index) {
    index *= 3;
    return new Vector3(_tangents[index], _tangents[index + 1], _tangents[index + 2]);
  }
  
  void setTangents(int index, data) {
    index *= 3;
    _tangents[index] = data[0];
    _tangents[index + 1] = data[1];
    _tangents[index + 2] = data[2];
  }

  Vector3 getVertex(int index) {
    index *= 3;
    return new Vector3(_positions[index], _positions[index + 1], _positions[index + 2]);
  }

  setVertex(int index, vertex) {
    index *= 3;
    _positions[index] = vertex[0];
    _positions[index + 1] = vertex[1];
    _positions[index + 2] = vertex[2];
  }

  //TODO : fixme
  addVertex(vertex) {
    _positions.add(vertex[0]);
    _positions.add(vertex[1]);
    _positions.add(vertex[2]);
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

  addNormal(normal) {
    _normals.add(normal[0]);
    _normals.add(normal[1]);
    _normals.add(normal[2]);
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

  addTexCoord(uv) {
    _texCoords.add(uv[0]);
    _texCoords.add(uv[1]);
  }

  addFace(face) {
    _indices.add(face[0]);
    _indices.add(face[1]);
    _indices.add(face[2]);
  }
}
















