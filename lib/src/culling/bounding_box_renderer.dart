part of orange;





class BoundingBoxRenderer {
  bool showBackLines = true;
  Color backColor = new Color(25, 25, 25);
  Color frontColor = new Color(255, 255, 255);
  GraphicsDevice _graphicsDevice;
  ShaderMaterial _material;
  List<BoundingBox> _renderList;
  BufferView _vertices;
  BufferView _indices;

  BoundingBoxRenderer(this._graphicsDevice) {
    _material = new ShaderMaterial(_graphicsDevice);
    _renderList = [];
    _vertices = new Cube().geometry.buffers[Semantics.position];
    var indices = new Uint16List.fromList([0, 1, 1, 2, 2, 3, 3, 0, 4, 5, 5, 6, 6, 7, 7, 4, 0, 7, 1, 6, 2, 5, 3, 4]);
    _indices = new BufferView(0, gl.UNSIGNED_SHORT, 0, 0, count: indices.length, data: indices, target: gl.ELEMENT_ARRAY_BUFFER);
  }

  void render() {
    if (!_material.ready()) return;
    if (_renderList.length == 0) return;

    var ctx = _graphicsDevice.ctx;
    var shader = _material.technique.pass.shader;

    _graphicsDevice.use(_material.technique.pass);
    _graphicsDevice.depthWrite = false;

    _renderList.forEach((boundingBox) {

      var min = boundingBox.minimum;
      var max = boundingBox.maximum;
      var diff = max - min;
      var median = min + diff.scale(0.5);

      var worldMatrix = new Matrix4.diagonal3(diff) * new Matrix4.translation(median) * boundingBox.worldMatrix;

      _vertices.enable(_graphicsDevice.ctx, shader.attributes[Semantics.position]);
      _indices.bind(ctx);

      if (this.showBackLines) {
        // Back
        _graphicsDevice.ctx.depthFunc(gl.GEQUAL);
        _graphicsDevice.bindUniform(shader, "color", backColor.rgb.storage);
        _material.bind(worldMatrix: worldMatrix);
        // Draw order
        ctx.drawElements(gl.LINES, 0, gl.UNSIGNED_SHORT, 0);
      }
      // Front
      _graphicsDevice.ctx.depthFunc(gl.LESS);
      _graphicsDevice.bindUniform(shader, "color", frontColor.rgb.storage);
      _material.bind(worldMatrix: worldMatrix);

      // Draw order
      ctx.drawElements(gl.LINES, 0, gl.UNSIGNED_SHORT, 0);
    });
  }


}
