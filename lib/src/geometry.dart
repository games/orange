part of orange;



class Geometry {
  int vertexCount;
  Map<String, BufferView> buffers = {};

  BoundingInfo _boundingInfo;

  BoundingInfo get boundingInfo {
    if (_boundingInfo == null && buffers.containsKey(Semantics.position)) {
      var minimum = new Vector3.all(double.MAX_FINITE);
      var maximum = new Vector3.all(-double.MAX_FINITE);
      var positions = buffers[Semantics.position].data as Float32List;
      var count = buffers[Semantics.position].count;
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
