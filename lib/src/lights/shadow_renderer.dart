part of orange;





class ShadowRenderer implements Renderer {

  DirectionalLight light;
  bool useVarianceShadowMap = true;

  double _darkness = 0.0;
  RenderTargetTexture _shadowMap;
  Pass _pass;
  String _cachedDefines;
  Matrix4 _viewMatrix;
  Matrix4 _projectionMatrix;
  Matrix4 _transformMatrix;

  ShadowRenderer(int size, this.light, GraphicsDevice device) {
    _shadowMap = RenderTargetTexture.create(device, size, size);
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
      // TODO cache ??
      if (_pass.shader != null) _pass.shader.dispose();
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
    if (!mesh.castShadows) return;
    if (mesh.faces != null) {
      var device = scene.graphicsDevice;
      var ctx = device.ctx;
      if (ready(mesh, device)) {
        var shader = _pass.shader;
        device.use(_pass);
        device.bindUniform(shader, "viewProjection", transformMatrix.storage);
        // TODO alpha test
        // bones
        var skeleton = mesh.skeleton;
        if (skeleton != null) {
          device.bindUniform(shader, "mBones", skeleton.jointMatrices);
        }
        device.bindUniform(shader, "world", mesh.worldMatrix.storage);
        if (mesh.geometry != null) {
          var geometry = mesh.geometry;
          shader.attributes.forEach((semantic, attrib) {
            if (geometry.buffers.containsKey(semantic)) {
              geometry.buffers[semantic].enable(ctx, attrib);
            }
          });
        }
        mesh.faces.bind(ctx);
        ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
      }
    }
    mesh.children.forEach((m) => _renderMesh(scene, m));
  }

  void _renderSubmesh(Scene scene, Mesh mesh) {
    var device = scene.graphicsDevice;
    var ctx = device.ctx;
    var shader = _pass.shader;

  }

  // TODO cache
  Matrix4 get transformMatrix {
    var lightPos = light.position;
    var lightDir = light.direction;
    _viewMatrix = new Matrix4.identity().lookAt(lightPos, lightPos + lightDir, Axis.UP);
    // TODO near and far should be from camera
    _projectionMatrix = new Matrix4.perspective(radians(90.0), 1.0, 0.01, 100.0);
    _transformMatrix = _projectionMatrix * _viewMatrix;
    return _transformMatrix;
  }

  RenderTargetTexture get shadowMap => _shadowMap;

  double get darkness => _darkness;

  void set darkness(double val) {
    if (val >= 1.0) _darkness = 1.0; else if (val <= 0.0) _darkness = 0.0; else _darkness = val;
  }
}
