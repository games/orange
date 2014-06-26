part of orange;




class RenderingGroup implements Renderer {
  Map<Pass, List<Mesh>> _transparentPasses = {};
  Map<Pass, List<Mesh>> _opaquePasses = {};

  int _lastMaxEnabledArray = -1;
  int _newMaxEnabledArray = -1;

  void register(Mesh mesh) {
    var material = mesh.material;
    if (material == null) return;
    if (!material.ready(mesh)) return;
    var pass = material.technique.pass;
    if (pass.blending) {
      _registerTo(_transparentPasses, pass, mesh);
    } else {
      _registerTo(_opaquePasses, pass, mesh);
    }
  }

  void _registerTo(Map<Pass, List<Mesh>> passes, Pass pass, Mesh mesh) {
    if (!passes.containsKey(pass)) passes[pass] = [];
    passes[pass].add(mesh);
  }

  void unregister(Mesh mesh) {
    var material = mesh.material;
    if (material == null) return;
    _transparentPasses.remove(material.technique.pass);
    _opaquePasses.remove(material.technique.pass);
  }

  void render(Scene scene, Matrix4 viewMatrix, Matrix4 viewProjectionMatrix, Matrix4 projectionMatrix, Vector3 eyePosition) {
    var graphics = scene.graphicsDevice;
    _opaquePasses.forEach((Pass pass, List<Mesh> meshes) {
      _renderMeshes(graphics, pass, meshes, viewMatrix, viewProjectionMatrix, projectionMatrix, eyePosition);
    });
    _transparentPasses.forEach((Pass pass, List<Mesh> meshes) {
      // TODO sorting
      _renderMeshes(graphics, pass, meshes, viewMatrix, viewProjectionMatrix, projectionMatrix, eyePosition);
    });
  }

  _renderMeshes(GraphicsDevice graphics, Pass pass, List<Mesh> meshes, Matrix4 viewMatrix, Matrix4 viewProjectionMatrix, Matrix4 projectionMatrix, Vector3 eyePosition) {
    _lastMaxEnabledArray = -1;
    var shader = pass.shader;
    var ctx = graphics.ctx;
    graphics.use(pass);
    graphics.bindMatrix4(Semantics.viewMat, viewMatrix);
    graphics.bindMatrix4(Semantics.viewProjectionMat, viewProjectionMatrix);
    graphics.bindMatrix4(Semantics.projectionMat, projectionMatrix);
    graphics.bindVector3(Semantics.cameraPosition, eyePosition);
    meshes.forEach((Mesh mesh) {
      if (mesh.faces != null) {
        var material = mesh.material;
        var globalIntensity = 1.0;
        globalIntensity *= material.alpha;
        if (globalIntensity < 0.00001) return;
        if (globalIntensity < 1.0 && !pass.blending) {
          ctx.enable(gl.BLEND);
          ctx.blendEquation(gl.FUNC_ADD);
          ctx.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
          _renderMesh(graphics, mesh, shader);
          ctx.disable(gl.BLEND);
        } else {
          _renderMesh(graphics, mesh, shader);
        }
      }
    });
  }

  _renderMesh(GraphicsDevice graphics, Mesh mesh, Shader shader) {
    _newMaxEnabledArray = -1;
    var ctx = graphics.ctx;
    var material = mesh.material;
    graphics.cullingState = material.backFaceCulling;
    material.bind(mesh: mesh);
    if (mesh.geometry != null) {
      var geometry = mesh.geometry;
      shader.attributes.forEach((semantic, attrib) {
        if (geometry.buffers.containsKey(semantic)) {
          geometry.buffers[semantic].enable(ctx, attrib);
          if (attrib.location > _newMaxEnabledArray) {
            _newMaxEnabledArray = attrib.location;
          }
        }
      });
    }
    for (var i = (_newMaxEnabledArray + 1); i < _lastMaxEnabledArray; i++) {
      ctx.disableVertexAttribArray(i);
    }
    mesh.faces.bind(ctx);
    if (material.wireframe) {
      ctx.drawArrays(gl.LINE_STRIP, 0, mesh.geometry.buffers[Semantics.position].count);
    } else {
      ctx.drawElements(mesh.primitive, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
    }
    _lastMaxEnabledArray = _newMaxEnabledArray;
    material.unbind();
  }

  void clear() {
    _transparentPasses.clear();
    _opaquePasses.clear();
  }
}
