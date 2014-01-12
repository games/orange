part of orange;



class Mesh {
  String name;
  Material material;
  Texture diffuse;
  List<Mesh> subMeshes = [];
  MeshAttribute indicesAttrib;
  Map<String, MeshAttribute> attributes;
  Skeleton skeleton;
  int jointOffset;
  int jointCount;
  gl.Buffer vertexBuffer;
  gl.Buffer indexBuffer;
}