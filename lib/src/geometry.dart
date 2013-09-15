part of orange;


class Geometry {
  List<double> vertices;
  List<double> normals;
  List<double> textureCoords;
  
  gl.Buffer vertexBuffer;
  gl.Buffer normalBuffer;
  gl.Buffer textureCoordsBuffer;
  
  prepare(Renderer renderer) {
    if(vertexBuffer == null) {
      vertexBuffer = renderer.ctx.createBuffer();
      renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
      renderer.ctx.bufferDataTyped(gl.ARRAY_BUFFER, new Float32List.fromList(vertices), gl.STATIC_DRAW);
    }
    if(normalBuffer == null && normals != null) {
      normalBuffer = renderer.ctx.createBuffer();
      renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, normalBuffer);
      renderer.ctx.bufferDataTyped(gl.ARRAY_BUFFER, new Float32List.fromList(normals), gl.STATIC_DRAW);
    }
    if(textureCoordsBuffer == null && textureCoords != null) {
      textureCoordsBuffer = renderer.ctx.createBuffer();
      renderer.ctx.bindBuffer(gl.ARRAY_BUFFER, textureCoordsBuffer);
      renderer.ctx.bufferDataTyped(gl.ARRAY_BUFFER, new Float32List.fromList(textureCoords), gl.STATIC_DRAW);
    }
  }
}