part of orange;



class Mesh {
  String name;
  String material;
  gl.Texture diffuse;
  List<Mesh> subMeshes = [];
  MeshAttribute indicesAttrib;
  Map<String, MeshAttribute> attributes;
  Skeleton skeleton;
  int jointOffset;
  int jointCount;
}