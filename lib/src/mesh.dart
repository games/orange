part of orange;



class Mesh extends Node {
  String name;
  Geometry _geometry;
  BufferView faces;
  Material material;
  Skeleton _skeleton;
  AnimationController animator;

  bool _receiveShadows = false;

  @deprecated
  int get vertexesCount {
    var geometry = this.geometry;
    if (geometry == null || !geometry.buffers.containsKey(Semantics.position)) return 0;
    return geometry.buffers[Semantics.position].count;
  }

  Geometry get geometry {
    if (_geometry == null && parent != null && parent is Mesh) return (parent as Mesh).geometry;
    return _geometry;
  }

  void set geometry(Geometry val) {
    _geometry = val;
  }

  Skeleton get skeleton {
    if (_skeleton == null && parent != null && parent is Mesh) return (parent as Mesh)._skeleton;
    return _skeleton;
  }

  void set skeleton(Skeleton val) {
    _skeleton = val;
  }

  bool get receiveShadows => _receiveShadows;

  void set receiveShadows(bool val) {
    _receiveShadows = val;
    children.forEach((c) {
      if (c is Mesh) c.receiveShadows = val;
    });
  }
}


class Submesh {
  Geometry geometry;
  BufferView faces;
  Material material;


}
