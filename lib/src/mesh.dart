part of orange;


class Mesh extends Transform {
  Geometry _geometry;
  Material _material;
  List<int> _faces;
  List<Mesh> _subMeshes;
  
  gl.Buffer _faceBuffer;
}