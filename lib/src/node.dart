part of orange;





class Node {
  gl.Buffer vertexBuffer;
  gl.Buffer indexBuffer;
  List<Mesh> meshes = [];
  Matrix4 matrix = new Matrix4.identity();
  Map<String, MeshAttribute> attributes;
  Skeleton skeleton;
  
  Node() {
  }
  
  destroy() {
  }
  
  bindBuffer(gl.RenderingContext ctx, Shader shader) {
    ctx.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
    ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
    attributes.forEach((sementic, accessor) {
      if(shader.attributes.containsKey(sementic)) {
        var attrib = shader.attributes[sementic];
        ctx.enableVertexAttribArray(attrib.location);
        ctx.vertexAttribPointer(attrib.location, accessor.size, accessor.type, accessor.normalized, accessor.stride, accessor.offset);
      }
    });
    
  }
}





































