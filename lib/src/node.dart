part of orange;





class Node {
  String name;
  Matrix4 _localMatrix;
  Matrix4 worldMatrix;
  Skeleton skeleton;
  Node parent;
  List<Node> children;
  
  Mesh mesh;
  
  Node() {
    _localMatrix = new Matrix4.identity();
    worldMatrix = new Matrix4.identity();
    children = [];
  }
  
  destroy() {
    //TODO destroy buffers
  }
  
  add(Node child) {
    child.removeFromParent();
    child.parent = this;
    children.add(child);
  }
  
  removeFromParent() {
    if(parent != null) {
      parent.children.remove(this);
      parent = null;
    }
  }
  
  translate(Vector3 translation) {
    _localMatrix.translate(translation);
  }
  
  scale(dynamic x, [double y = null, double z = null]) {
    _localMatrix.scale(x, y, z);
  }
  
  rotate(double angle, Vector3 axis) {
    _localMatrix.rotate(angle, axis);
  }
  
  rotateX(double rad) {
    _localMatrix.rotateX(rad);
  }
  
  rotateY(double rad) {
    _localMatrix.rotateY(rad);
  }
  
  rotateZ(double rad) {
    _localMatrix.rotateZ(rad);
  }
  
  applyMatrix(Matrix4 m) {
    _localMatrix.multiply(m);
  }
  
  updateMatrix() {
    if(parent != null) {
      worldMatrix = parent._localMatrix * worldMatrix;
    } else {
      worldMatrix = _localMatrix.clone();
    }
    children.forEach((c) => c.updateMatrix());
  }
  
  bindBuffer(gl.RenderingContext ctx, Shader shader) {
    if(mesh.vertexBuffer != null)
      ctx.bindBuffer(gl.ARRAY_BUFFER, mesh.vertexBuffer);
    if(mesh.indexBuffer != null)
      ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.indexBuffer);
  }
}





































