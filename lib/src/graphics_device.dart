part of orange;


class GraphicsDevice {
  html.CanvasElement _renderingCanvas;
  gl.RenderingContext ctx;
  int _lastMaxEnabledArray = -1;
  int _newMaxEnabledArray = -1;
  DeviceCapabilities _caps;
  bool _depthMask = false;
  bool _cullingState;
  bool _cullBackFaces = true;
  Pass _currentPass;

  html.Rectangle<int> _cachedViewport;
  RenderTargetTexture _currentRenderTarget;
  List<RenderTargetTexture> _renderTargets = [];
  RenderingGroup _renderGroup = new RenderingGroup();

  GraphicsDevice(this._renderingCanvas) {
    ctx = _renderingCanvas.getContext3d(preserveDrawingBuffer: true);
    depthWrite = true;
    depthBuffer = true;
    ctx.depthFunc(gl.LEQUAL);
    viewport(0, 0, _renderingCanvas.width, _renderingCanvas.height);

    _caps = new DeviceCapabilities();
    _caps.maxTexturesImageUnits = ctx.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS);
    _caps.maxTextureSize = ctx.getParameter(gl.MAX_TEXTURE_SIZE);
    _caps.maxCubemapTextureSize = ctx.getParameter(gl.MAX_CUBE_MAP_TEXTURE_SIZE);
    _caps.maxRenderTextureSize = ctx.getParameter(gl.MAX_RENDERBUFFER_SIZE);

    // extensions
    _caps.standardDerivatives = (ctx.getExtension('OES_standard_derivatives') != null);

    _caps.s3tc = ctx.getExtension('WEBGL_compressed_texture_s3tc');
    _caps.textureFloat = (ctx.getExtension('OES_texture_float') != null);
    _caps.textureAnisotropicFilterExtension = ctx.getExtension('EXT_texture_filter_anisotropic');
    if (_caps.textureAnisotropicFilterExtension == null) _caps.textureAnisotropicFilterExtension = ctx.getExtension('WEBKIT_EXT_texture_filter_anisotropic');
    if (_caps.textureAnisotropicFilterExtension == null) _caps.textureAnisotropicFilterExtension = ctx.getExtension('MOZ_EXT_texture_filter_anisotropic');
    if (_caps.textureAnisotropicFilterExtension == null) {
      _caps.maxAnisotropy = 0;
    } else {
      _caps.maxAnisotropy = ctx.getParameter(gl.ExtTextureFilterAnisotropic.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
    }
    _caps.instancedArrays = ctx.getExtension('ANGLE_instanced_arrays');
  }

  void clear(Color color, {bool backBuffer: false, bool depthStencil: false}) {
    ctx.clearColor(color.red, color.green, color.blue, color.alpha);
    if (_depthMask) ctx.clearDepth(1.0);
    var mode = 0;
    if (backBuffer) mode |= gl.COLOR_BUFFER_BIT;
    if (depthStencil && _depthMask) mode |= gl.DEPTH_BUFFER_BIT;
    ctx.clear(mode);
  }

  void set depthWrite(bool enable) {
    ctx.depthMask(enable);
    _depthMask = enable;
  }

  void set depthBuffer(bool enable) {
    if (enable) {
      ctx.enable(gl.DEPTH_TEST);
    } else {
      ctx.disable(gl.DEPTH_TEST);
    }
  }

  void viewport(int x, int y, int width, int height) {
    _cachedViewport = new html.Rectangle(x, y, width, height);
    ctx.viewport(x, y, width, height);
  }

  void bindFramebuffer(RenderTargetTexture texture) {
    _currentRenderTarget = texture;
    ctx.bindFramebuffer(gl.FRAMEBUFFER, texture.framebuffer);
    ctx.viewport(0, 0, texture.width, texture.height);
    wipeCaches();
  }

  void unbindFramebuffer() {
    _currentRenderTarget = null;
    ctx.bindFramebuffer(gl.FRAMEBUFFER, null);
  }

  void restoreDefaultFramebuffer() {
    ctx.bindFramebuffer(gl.FRAMEBUFFER, null);
    viewport(_cachedViewport.left, _cachedViewport.top, _cachedViewport.width, _cachedViewport.height);
    wipeCaches();
  }

  void wipeCaches() {
    // TODO
  }

  use(Pass pass) {
    if (_currentPass == null || _currentPass.shader.program != pass.shader.program) {
      _currentPass = pass;
      pass.bind(this);
      for (var i = 0; i < pass.shader.sampers.length; i++) {
        var uniform = pass.shader.uniforms[pass.shader.sampers[i]];
        ctx.uniform1i(uniform.location, i);
      }
    }
  }

  void render(Scene scene) {

    _renderTargets.forEach((renderTarget) {
      renderTarget.render(scene, scene._opaqueMeshes);
    });

    if (_renderTargets.length > 0) restoreDefaultFramebuffer();
    clear(scene.backgroundColor, backBuffer: scene.autoClear || scene.forceWireframe, depthStencil: true);

    var nonOpaquePasses = {};
    _renderGroup._meshesPerPass.forEach((Pass pass, List<Mesh> meshes) {
      if (pass.blending) {
        nonOpaquePasses[pass] = meshes;
      } else {
        _renderMeshes(scene, pass, meshes);
      }
    });
    nonOpaquePasses.forEach((Pass pass, List<Mesh> meshes) {
      // TODO sorting
      _renderMeshes(scene, pass, meshes);
    });

    // reset
    // TODO : should dispose the renderTargets ?
    _renderTargets.clear();
  }

  _renderMeshes(Scene scene, Pass pass, List<Mesh> meshes) {
    _lastMaxEnabledArray = -1;
    use(pass);
    var camera = scene.camera;
    var shader = pass.shader;
    bindMatrix4(Semantics.viewMat, camera.viewMatrix);
    bindMatrix4(Semantics.viewProjectionMat, camera.viewProjectionMatrix);
    bindMatrix4(Semantics.projectionMat, camera.projectionMatrix);
    bindVector3(Semantics.cameraPosition, camera.position);

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
          _renderMesh(mesh, shader);
          ctx.disable(gl.BLEND);
        } else {
          _renderMesh(mesh, shader);
        }
      }
    });
  }

  _renderMesh(Mesh mesh, Shader shader) {
    _newMaxEnabledArray = -1;
    var material = mesh.material;
    cullingState = material.backFaceCulling;
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

  ShaderProperty uniform(String symbol) => _currentPass.shader.uniforms[symbol];

  void bindList(String symbol, Float32List value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniform1fv(uniform(symbol).location, value);
  }
  bindVector3(String symbol, Vector3 value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniform3fv(uniform(symbol).location, value.storage);
  }
  bindMatrix4(String symbol, Matrix4 value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniformMatrix4fv(uniform(symbol).location, false, value.storage);
  }
  bindMatrix4List(String symbol, Float32List value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniformMatrix4fv(uniform(symbol).location, false, value);
  }
  bindMatrix3(String symbol, Matrix3 value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniformMatrix3fv(uniform(symbol).location, false, value.storage);
  }
  bindMatrix3List(String symbol, Float32List value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniformMatrix3fv(uniform(symbol).location, false, value);
  }
  bindFloat(String symbol, num value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniform1f(uniform(symbol).location, value);
  }
  bindFloat2(String symbol, num x, num y) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniform2f(uniform(symbol).location, x, y);
  }
  bindFloat3(String symbol, num x, num y, num z) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniform3f(uniform(symbol).location, x, y, z);
  }
  bindFloat4(String symbol, num x, num y, num z, num w) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniform4f(uniform(symbol).location, x, y, z, w);
  }
  bindBool(String symbol, bool value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniform1i(uniform(symbol).location, value ? 1 : 0);
  }
  bindInt(String symbol, int value) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) ctx.uniform1i(uniform(symbol).location, value);
  }
  bindColor3(String symbol, Color color) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) bindFloat3(symbol, color.red, color.green, color.blue);
  }
  bindColor4(String symbol, Color color) {
    if (_currentPass.shader.uniforms.containsKey(symbol)) bindFloat4(symbol, color.red, color.green, color.blue, color.alpha);
  }

  bindTexture(String sampler, Texture texture) {
    if (!_currentPass.shader.ready) return;
    var textureChannel = _currentPass.shader.sampers.indexOf(sampler);
    if (textureChannel < 0) return;
    ctx.activeTexture(gl.TEXTURE0 + textureChannel);
    ctx.bindTexture(texture.target, texture.data);
  }

  enableState(int cap, bool enable) {
    if (enable) {
      ctx.enable(cap);
    } else {
      ctx.disable(cap);
    }
  }

  void set cullingState(bool val) {
    if (_cullingState != val) {
      if (val) {
        ctx.cullFace(_cullBackFaces ? gl.BACK : gl.FRONT);
        ctx.enable(gl.CULL_FACE);
      } else {
        ctx.disable(gl.CULL_FACE);
      }
      _cullingState = val;
    }
  }

  DeviceCapabilities get caps => _caps;
}


class DeviceCapabilities {
  int maxTexturesImageUnits;
  num maxTextureSize;
  num maxCubemapTextureSize;
  num maxRenderTextureSize;
  bool standardDerivatives;
  gl.CompressedTextureS3TC s3tc;
  bool textureFloat;
  gl.ExtTextureFilterAnisotropic textureAnisotropicFilterExtension;
  num maxAnisotropy;
  gl.AngleInstancedArrays instancedArrays;
}
