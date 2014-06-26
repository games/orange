part of orange;



class Geometry {
  String id;

  @deprecated
  int vertexCount;

  Map<String, VertexBuffer> buffers = {};

  Geometry();

  void set positions(data) {
    if (data is VertexBuffer) {
      buffers[Semantics.position] = data;
      return;
    }
    if (!(data is Float32List)) data = new Float32List.fromList(data);
    buffers[Semantics.position] = new VertexBuffer(3, gl.FLOAT, 0, 0, count: data.length ~/ 3, data: data);
    _boundingInfo = null;
  }

  VertexBuffer get positions => buffers[Semantics.position];

  void set normals(data) {
    if (data is VertexBuffer) {
      buffers[Semantics.normal] = data;
      return;
    }
    if (!(data is Float32List)) data = new Float32List.fromList(data);
    buffers[Semantics.normal] = new VertexBuffer(3, gl.FLOAT, 0, 0, count: data.length ~/ 3, data: data);
  }

  VertexBuffer get normals => buffers.containsKey(Semantics.normal) ? buffers[Semantics.normal] : null;

  void set texCoords(data) {
    if (data is VertexBuffer) {
      buffers[Semantics.texcoords] = data;
      return;
    }
    if (!(data is Float32List)) data = new Float32List.fromList(data);
    buffers[Semantics.texcoords] = new VertexBuffer(2, gl.FLOAT, 0, 0, count: data.length ~/ 2, data: data);
  }

  void set texCoords2(data) {
    if (data is VertexBuffer) {
      buffers[Semantics.texcoords2] = data;
      return;
    }
    if (!(data is Float32List)) data = new Float32List.fromList(data);
    buffers[Semantics.texcoords2] = new VertexBuffer(2, gl.FLOAT, 0, 0, count: data.length ~/ 2, data: data);
  }

  void set indices(data) {
    if (data is VertexBuffer) {
      buffers[Semantics.indices] = data;
      return;
    }
    if (!(data is Uint16List)) data = new Uint16List.fromList(data);
    buffers[Semantics.indices] = new VertexBuffer(0, gl.UNSIGNED_SHORT, 0, 0, count: data.length, data: data, target: gl.ELEMENT_ARRAY_BUFFER);
  }

  VertexBuffer get indices => buffers[Semantics.indices];

  BoundingInfo _boundingInfo;

  BoundingInfo get boundingInfo {
    if (_boundingInfo == null && buffers.containsKey(Semantics.position)) {
      var minimum = new Vector3.all(double.MAX_FINITE);
      var maximum = new Vector3.all(-double.MAX_FINITE);
      var verts = positions.data as Float32List;
      var count = positions.count;
      for (var index = 0; index < count; index++) {
        var current = new Vector3(verts[index * 3], verts[index * 3 + 1], verts[index * 3 + 2]);
        Vector3.min(current, minimum, minimum);
        Vector3.max(current, maximum, maximum);
      }
      _boundingInfo = new BoundingInfo(minimum, maximum);
    }
    return _boundingInfo;
  }

  Geometry clone() {
    var result = new Geometry();
    buffers.forEach((k, v) {
      result.buffers[k] = v;
    });
    return result;
  }


}
