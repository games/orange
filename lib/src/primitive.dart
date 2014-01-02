part of orange;


class Primitive {
  MeshAttribute indices;
  Map<String, MeshAttribute> attributes;
  Material material;
  int primitive;
  
  bool get ready => indices.buffer != null && attributes.keys.every((k) => attributes[k].buffer != null);
  
  setupBuffer(gl.RenderingContext ctx) {
    indices.setupBuffer(ctx);
    attributes.forEach((k, v){
      v.setupBuffer(ctx);
    });
  }
}















