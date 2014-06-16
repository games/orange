part of orange;



class Mesh extends Node {
  String name;
  Geometry geometry;
  BufferView faces;
  Material material;
  Skeleton skeleton;
  AnimationController animator;
  
  bool receiveShadows = false;
  
  int get vertexesCount {
    if (geometry == null || !geometry.buffers.containsKey(Semantics.position)) return 0;
    return geometry.buffers[Semantics.position].count;
  }
}
