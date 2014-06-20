part of orange;


class GraphicsDevice {
  html.CanvasElement _renderingCanvas;
  gl.RenderingContext ctx;
  int _lastMaxEnabledArray = -1;
  int _textureIndex = -1;
  int _newMaxEnabledArray = -1;
  DeviceCapabilities _caps;
  StandardMaterial defaultMaterial;
  bool _depthMask = false;

  html.Rectangle<int> _cachedViewport;
  RenderTargetTexture _currentRenderTarget;
  List<RenderTargetTexture> _renderTargets = [];

  GraphicsDevice(this._renderingCanvas) {
    ctx = _renderingCanvas.getContext3d(preserveDrawingBuffer: true);
    //    ctx.enable(gl.DEPTH_TEST);
    //    ctx.depthMask(true);
    //    ctx.depthFunc(gl.LEQUAL);
    //    ctx.frontFace(gl.CCW);
    //    ctx.cullFace(gl.BACK);
    //    ctx.enable(gl.CULL_FACE);
    //    ctx.clearDepth(1.0);

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
    if (_caps.textureAnisotropicFilterExtension == null) _caps.maxAnisotropy = 0; else _caps.maxAnisotropy = ctx.getParameter(gl.ExtTextureFilterAnisotropic.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
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
    if (enable) ctx.enable(gl.DEPTH_TEST); else ctx.disable(gl.DEPTH_TEST);
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


  //actions
  //befor render
  //animations
  //physics
  //clear
  //shadows
  //render
  void render(Scene scene) {
    scene.camera.updateMatrix();
    scene._nodes.forEach((n) => n.updateMatrix());

    // shadows
    scene._lights.forEach((light) {
      if (light is DirectionalLight && light.enabled) {
        if (light.shadowRenderer == null) light.shadowRenderer = new ShadowRenderer(512, light, this);
        _renderTargets.add(light.shadowRenderer.shadowMap);
      }
    });

    _renderTargets.forEach((renderTarget) {
      renderTarget.render(scene, scene._opaqueMeshes);
    });

    if (_renderTargets.length > 0) restoreDefaultFramebuffer();
    clear(scene.backgroundColor, backBuffer: scene.autoClear || scene.forceWireframe, depthStencil: true);
    scene._nodes.forEach((node) {
      _renderNode(node);
    });

    // reset
    // TODO : should dispose the renderTargets ?
    _renderTargets.clear();
  }

  _renderNode(Node node) {
    _textureIndex = -1;
    _newMaxEnabledArray = -1;
    if (node is Mesh) {
      _drawMesh(node);
    }
  }

  _drawMesh(Mesh mesh) {
    var scene = mesh.scene;
    var material = mesh.material;
    if (mesh.faces != null && material != null && material.ready(mesh)) {
      var shader = material.technique.pass.shader;
      use(material.technique.pass);
      material.bind(mesh);
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
      _lastMaxEnabledArray = _newMaxEnabledArray;

      mesh.faces.bind(ctx);
      if (material.wireframe) {
        ctx.drawArrays(gl.LINE_LOOP, 0, mesh.geometry.buffers[Semantics.position].count);
      } else {
        ctx.drawElements(gl.TRIANGLES, mesh.faces.count, mesh.faces.type, mesh.faces.offset);
      }
      material.unbind();
    }
    mesh.children.forEach((c) => _drawMesh(c));
  }

  use(Pass pass) {
    pass.bind(ctx);
  }

  // TODO should not pass the shader again.
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
          ctx.uniform2fv(property.location, value);
          break;
        case gl.FLOAT_VEC3:
          ctx.uniform3fv(property.location, value);
          break;
        case gl.FLOAT_VEC4:
          ctx.uniform4fv(property.location, value);
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

  bindTexture(Shader shader, String sampler, Texture texture) {
    _textureIndex++;
    ctx.activeTexture(gl.TEXTURE0 + _textureIndex);
    ctx.bindTexture(texture.target, texture.data);
    bindUniform(shader, sampler, _textureIndex);
  }

  enableState(int cap, bool enable) {
    if (enable) ctx.enable(cap); else ctx.disable(cap);
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
