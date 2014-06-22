part of orange;



class Geometry {
  @deprecated
  int vertexCount;
  
  Map<String, BufferView> buffers = {};

  void set vertices(data) {
    if (!(data is Float32List)) 
      data = new Float32List.fromList(data);
    buffers[Semantics.position] = new BufferView(3, gl.FLOAT, 0, 0, count: data.length ~/ 3, data: data);
    _boundingInfo = null;
  }

  BufferView get vertices => buffers[Semantics.position];
  
  void set normals(data) {
    if(!(data is Float32List)) data = new Float32List.fromList(data);
    buffers[Semantics.normal] = new BufferView(3, gl.FLOAT, 0, 0, count: data.length ~/ 3, data: data);
  }
  
  BufferView get normals => buffers.containsKey(Semantics.normal) ? buffers[Semantics.normal] : null;

  void set texCoords(data) {
    if(!(data is Float32List)) data = new Float32List.fromList(data);
    buffers[Semantics.texcoords] = new BufferView(2, gl.FLOAT, 0, 0, count: data.length ~/ 2, data: data);
  }

  BoundingInfo _boundingInfo;

  BoundingInfo get boundingInfo {
    if (_boundingInfo == null && buffers.containsKey(Semantics.position)) {
      var minimum = new Vector3.all(double.MAX_FINITE);
      var maximum = new Vector3.all(-double.MAX_FINITE);
      var positions = vertices.data as Float32List;
      var count = vertices.count;
      for (var index = 0; index < count; index++) {
        var current = new Vector3(positions[index * 3], positions[index * 3 + 1], positions[index * 3 + 2]);
        Vector3.min(current, minimum, minimum);
        Vector3.max(current, maximum, maximum);
      }
      _boundingInfo = new BoundingInfo(minimum, maximum);
    }
    return _boundingInfo;
  }
}
