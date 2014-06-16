part of orange;


class Renderer2 {
  html.CanvasElement _canvas;
  gl.RenderingContext ctx;
  int _lastMaxEnabledArray = -1;
  int _textureIndex = -1;
  int _newMaxEnabledArray = -1;

  Renderer2(this._canvas) {
    ctx = _canvas.getContext3d(preserveDrawingBuffer: true);
    ctx.enable(gl.DEPTH_TEST);
    ctx.frontFace(gl.CCW);
    ctx.cullFace(gl.BACK);
    ctx.enable(gl.CULL_FACE);
    ctx.clearDepth(1.0);
  }

  prepare() {
  }

  render(Scene scene) {
    ctx.viewport(0, 0, _canvas.width, _canvas.height);
    ctx.clearColor(scene.backgroundColor.red, scene.backgroundColor.green, scene.backgroundColor.blue, scene.backgroundColor.alpha);
    ctx.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    scene.camera.updateMatrix();
    scene.nodes.forEach((node) {
      node.updateMatrix();
      _renderNode(scene, node);
    });
  }

  _renderNode(Scene scene, Node node) {
    _textureIndex = -1;
    _newMaxEnabledArray = -1;
    if (node is Mesh) {
      _drawMesh(scene, node);
    }
  }

  _drawMesh(Scene scene, Mesh mesh) {
    var material = mesh.material;
    if(!material.ready(mesh)) return;
    
    var shader = material.technique.pass.shader;
    material.bind(this, scene, mesh);
    if (mesh.geometry != null) {
      var geometry = mesh.geometry;
      shader.attributes.forEach((semantic, attrib) {
        if (geometry.buffers.containsKey(semantic)) {
          var bufferView = geometry.buffers[semantic];
          bufferView.bindBuffer(ctx);
          ctx.enableVertexAttribArray(attrib.location);
          ctx.vertexAttribPointer(attrib.location, bufferView.size, bufferView.type, bufferView.normalized, bufferView.stride, bufferView.offset);
          if (attrib.location > _newMaxEnabledArray) {
            _newMaxEnabledArray = attrib.location;
          }
        }
      });
    }
    for (var i = (_newMaxEnabledArray + 1); i < _lastMaxEnabledArray; i++) {
      ctx.disableVertexAttribArray(i);
    }
    _lastMaxEnabledArray = _newMaxEnabledArray;
    if (mesh.faces != null) {
      mesh.faces.bindBuffer(ctx);
      if (material.wireframe) {
        ctx.drawArrays(gl.LINE_LOOP, 0, mesh.geometry.buffers[Semantics.position].count);
      } else {
        ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
      }
    } else {
      ctx.drawArrays(gl.TRIANGLES, 0, mesh.vertexesCount);
    }
    mesh.children.forEach((c) => _drawMesh(scene, c));
  }

  use(Pass pass) {
    pass.bind(ctx);
  }

  bindUniform(Shader shader, String symbol, value) {
    if (!shader.ready) return;
    if (shader.uniforms.containsKey(symbol) && value != null) {
      var property = shader.uniforms[symbol];
      switch (property.type) {
        case gl.BYTE:
        case gl.UNSIGNED_BYTE:
        case gl.SHORT:
        case gl.UNSIGNED_SHORT:
          ctx.uniform1i(property.location, value);
          break;
        case gl.FLOAT_MAT2:
          ctx.uniformMatrix2fv(property.location, false, value);
          break;
        case gl.FLOAT_MAT3:
          ctx.uniformMatrix3fv(property.location, false, value);
          break;
        case gl.FLOAT_MAT4:
          ctx.uniformMatrix4fv(property.location, false, value);
          break;
        case gl.FLOAT:
          ctx.uniform1f(property.location, value);
          break;
        case gl.FLOAT_VEC2:
          ctx.uniform2fv(property.location, value.storage);
          break;
        case gl.FLOAT_VEC3:
          ctx.uniform3fv(property.location, value);
          break;
        case gl.FLOAT_VEC4:
          ctx.uniform4fv(property.location, value.storage);
          break;
        case gl.INT:
          ctx.uniform1i(property.location, value);
          break;
        case gl.SAMPLER_2D:
          ctx.uniform1i(property.location, value);
          break;
        case gl.SAMPLER_CUBE:
          ctx.uniform1i(property.location, value);
          break;
        case gl.BOOL:
          ctx.uniform1i(property.location, value ? 1 : 0);
      }
    }
  }

  bindTexture(Shader shader, Texture texture) {
    _textureIndex++;
    ctx.activeTexture(gl.TEXTURE0 + _textureIndex);
    ctx.bindTexture(texture.target, texture.data);
    bindUniform(shader, Semantics.texture, _textureIndex);
    bindUniform(shader, Semantics.useTextures, true);
  }

  setState(int cap, bool enable) {
    if (enable) ctx.enable(cap); else ctx.disable(cap);
  }
}



