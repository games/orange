part of orange;


class Mesh extends Transform {
  Geometry _geometry;
  Material _material;
  
  List<int> _faces;
  gl.Buffer _faceBuffer;
  
  List<Mesh> _subMeshes;
  
  render() {
    matrix.setIdentity();
    matrix.translate(position);
    matrix.scale(scale);
    matrix.rotateX(rotation.x);
    matrix.rotateY(rotation.y);
    matrix.rotateZ(rotation.z);
    
    Renderer renderer = _director.renderer;
    
    if(_geometry != null) {
      _geometry.prepare(renderer);
    }
    
    if(_material != null) {
      _material.shader.compile();
      _material.shader.use();
      _material.shader.setupAttributes(this);
      _material.shader.setupUniforms(this);
      _material.shader.setupLights(_director.scene.lights);
    }
    
    if(_faceBuffer == null && _faces != null) {
      _faceBuffer = renderer.ctx.createBuffer();
      renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _faceBuffer);
      renderer.ctx.bufferDataTyped(gl.ELEMENT_ARRAY_BUFFER, new Uint16List.fromList(_faces), gl.STATIC_DRAW);
    } 
    
    if(_faceBuffer != null) {
      renderer.ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, _faceBuffer);
      renderer.ctx.drawElements(gl.TRIANGLES, _faces.length, gl.UNSIGNED_SHORT, 0);
    }
    
    if(_subMeshes != null)
      _subMeshes.forEach((Mesh e) => e.render());
  }
}

















