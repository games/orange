part of orange;



class Mesh {
  String name;
  String material;
  gl.Texture diffuse;
  List<Mesh> subMeshes = [];
  MeshAttribute indicesAttrib;
  int jointOffset;
  int jointCount;
}