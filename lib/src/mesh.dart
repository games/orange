part of orange;



class Mesh extends Node {
  String name;
  Geometry geometry;
  Float32List bonesAssignments;
  gl.Buffer faces;
  Material material;
  Skeleton skeleton;
}