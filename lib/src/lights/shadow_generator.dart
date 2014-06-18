part of orange;





class ShadowGenerator implements Renderer {

  DirectionalLight light;
  bool useVarianceShadowMap = true;

  double _darkness = 0.5;
  RenderTargetTexture _shadowMap;
  Pass _pass;
  String _cachedDefines;
  Matrix4 _viewMatrix;
  Matrix4 _projectionMatrix;
  Matrix4 _transformMatrix;

  ShadowGenerator(int size, this.light, GraphicsDevice renderer) {
    _shadowMap = RenderTargetTexture.create(renderer, size, size);
    _shadowMap.renderDelegate = this;
    _pass = new Pass();
  }

  bool ready(Mesh mesh, GraphicsDevice device) {
    var defines = [];
    if (useVarianceShadowMap) {
      defines.add("#define VSM");
    }
    // TODO alpha test
    // bones
    if (mesh.skeleton != null) {
      defines.add("#define BONES");
      defines.add("#define BonesPerMesh ${mesh.skeleton.joints.length}");
    }
    var finalDefines = defines.join("\n");
    if (_cachedDefines != finalDefines) {
      _cachedDefines = finalDefines;
      _pass.shader = new Shader(device.ctx, SHADER_SHADOW_VS, SHADER_SHADOW_FS, common: finalDefines);
    }
    return _pass.shader.ready;
  }

  void render(Scene scene, List<Mesh> opaqueMeshes, {List<Mesh> alphaTestMeshes, List<Mesh> transparentMeshes}) {
    opaqueMeshes.forEach((mesh) => _renderMesh(scene, mesh));
    if (alphaTestMeshes != null) opaqueMeshes.forEach((mesh) => _renderMesh(scene, mesh));
    if (transparentMeshes != null) opaqueMeshes.forEach((mesh) => _renderMesh(scene, mesh));
  }

  void _renderMesh(Scene scene, Mesh mesh) {
    var device = scene.device;
    var ctx = device.ctx;
    if (ready(mesh, device)) {
      var shader = _pass.shader;
      device.use(_pass);
      device.bindUniform(shader, "viewProjection", transformMatrix.storage);
      _renderSubmesh(scene, mesh);
      mesh.children.forEach((m) => _renderSubmesh(scene, m));
    }
  }

  void _renderSubmesh(Scene scene, Mesh mesh) {
    var device = scene.device;
    var ctx = device.ctx;
    var shader = _pass.shader;
    // TODO alpha test
    // bones
    var skeleton = mesh.skeleton;
    if (skeleton != null) {
      device.bindUniform(shader, "mBones", skeleton.jointMatrices);
    }
    if (mesh.geometry != null) {
      var geometry = mesh.geometry;
      shader.attributes.forEach((semantic, attrib) {
        if (geometry.buffers.containsKey(semantic)) {
          var bufferView = geometry.buffers[semantic];
          bufferView.bindBuffer(ctx);
          ctx.enableVertexAttribArray(attrib.location);
          ctx.vertexAttribPointer(attrib.location, bufferView.size, bufferView.type, bufferView.normalized, bufferView.stride, bufferView.offset);
        }
      });
    }
    if (mesh.faces != null) {
      mesh.faces.bindBuffer(ctx);
      ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
    }
  }

  Matrix4 get transformMatrix {
    var lightPos = light.position;
    var lightDir = light.direction;
    _viewMatrix = new Matrix4.identity().lookAt(lightPos, lightPos + lightDir, Axis.UP);
    _projectionMatrix = new Matrix4.perspective(90.0, 1.0, 0.01, 100.0);
    _transformMatrix = _projectionMatrix * _viewMatrix;
    return _transformMatrix;
  }

  RenderTargetTexture get shadowMap => _shadowMap;

  double get darkness => _darkness;

  void set darkness(double val) {
    if (val >= 1.0) _darkness = 1.0; else if (val <= 0.0) _darkness = 0.0; else _darkness = val;
  }
}
