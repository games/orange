part of orange;



class PolygonMesh extends Mesh {

  Float32List _positions;
  Float32List _normals;
  Float32List _texCoords;
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

  Vector3 getVertex(int index) {
    index *= 3;
    if (index + 2 >= _positions.length) {
      print(index);
    }
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

















