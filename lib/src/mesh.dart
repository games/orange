part of orange;



class Mesh {
  String defaultTexture;
  String material;
  gl.Texture diffuse;
  List<Mesh> subMeshes = [];
  int indexCount;
  int indexOffset;
  int boneOffset;
  int boneCount;
}