part of orange;


class Primitive {
  MeshAttribute indices;
  Map<String, MeshAttribute> attributes;
  Material material;
  int primitive;
  Float32List jointMatrices;
  
  bool get ready => 
      indices.ready && 
      attributes.keys.every((k) => attributes[k].ready);
  
  setupBuffer(gl.RenderingContext ctx) {
    indices.setupBuffer(ctx);
    attributes.forEach((k, v){
      v.setupBuffer(ctx);
    });
  }
}















