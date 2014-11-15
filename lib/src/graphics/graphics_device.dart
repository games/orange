/*
  Orange : Simplified BSD License

  Copyright (c) 2014, Valor Zhong
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the 
  following conditions are met:
  
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following 
     disclaimer.
    
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the 
     following disclaimer in the documentation and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  
 */

part of orange;



const int SIZE_FLOAT = 4;

class GraphicsDevice {

  html.CanvasElement _renderingCanvas;
  html.CanvasElement get renderingCanvas => _renderingCanvas;
  gl.RenderingContext _ctx;
  DeviceCapabilities caps;
  Math.Rectangle _viewport;
  bool _currentDepthMask;
  VertexBuffer _currentIndexBuffer;

  GraphicsDevice(html.CanvasElement canvas) {
    _renderingCanvas = canvas;
    _ctx = _renderingCanvas.getContext3d(preserveDrawingBuffer: true);
    if (_ctx == null) throw new Exception("WebGL is not supported");

    caps = new DeviceCapabilities(_ctx);
    setRenderState(new RenderState());

    configureViewport(0, 0, _renderingCanvas.width, _renderingCanvas.height);
  }

  void configureViewport(int x, int y, int width, int height) {
    if (_viewport == null ||
        _viewport.left != x ||
        _viewport.right != y ||
        _viewport.width != width ||
        _viewport.height != height) {
      _viewport = new Math.Rectangle(x, y, width, height);
      _ctx.viewport(_viewport.left, _viewport.top, _viewport.width, _viewport.height);
    }
  }

  void clear(Color color, {double depth: 1.0, int stencil: 1, int mask: gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT}) {
    _ctx.clearColor(color.red, color.green, color.blue, color.alpha);
    _ctx.clearDepth(depth);
    _ctx.clearStencil(stencil);
    mask = (gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT | gl.STENCIL_BUFFER_BIT) & mask;
    if (mask & gl.DEPTH_BUFFER_BIT == gl.DEPTH_BUFFER_BIT) {
      _currentDepthMask = true;
      _ctx.depthMask(_currentDepthMask);
    }
    _ctx.clear(mask);
  }

  gl.Buffer createBuffer() {
    return _ctx.createBuffer();
  }

  void deleteBuffer(VertexBuffer vertexBuffer) {
    _ctx.deleteBuffer(vertexBuffer._bufferHandle);
  }

  void bindBuffer(VertexBuffer vertexBuffer) {
    _ctx.bindBuffer(vertexBuffer._target, vertexBuffer._bufferHandle);
  }

  void uploaderBufferData(VertexBuffer vertexBuffer) {
    bindBuffer(vertexBuffer);
    _ctx.bufferDataTyped(vertexBuffer._target, vertexBuffer._data, vertexBuffer._usage);
  }

  void enableBuffer(int location, VertexBuffer vertexBuffer) {
    bindBuffer(vertexBuffer);
    _ctx.enableVertexAttribArray(location);
    var attribute = vertexBuffer._attribute;
    _ctx.vertexAttribPointer(
        location,
        attribute.size,
        attribute.type,
        attribute.normalized,
        attribute.stride,
        attribute.offset);
  }

  void useEffect(Effect effect) {
    _ctx.useProgram(effect.program);
  }

  void setRenderState(RenderState renderState) {
    // TODO cache
    _setBlendMode(
        renderState.blend,
        blendColor: renderState.blendColor,
        blendEquationSeparate: renderState.blendEquationSeparate,
        blendFuncSeparate: renderState.blendFuncSeparate);
    _setCullingState(renderState.cullFaceEnabled, renderState.cullFace);
    _setDepthBuffer(renderState.depthTest, renderState.depthFunc);
    _setDepthWrite(renderState.depthMask);
    // TODO more
  }

  void _setBlendMode(bool enabled, {Color blendColor: null, List<int> blendEquationSeparate: null,
      List<int> blendFuncSeparate: null}) {
    if (enabled) {
      _ctx.enable(gl.BLEND);
      if (blendColor != null) {
        _ctx.blendColor(blendColor.red, blendColor.green, blendColor.blue, blendColor.alpha);
      }
      if (blendEquationSeparate != null) {
        _ctx.blendEquationSeparate(blendEquationSeparate[0], blendEquationSeparate[1]);
      }
      if (blendFuncSeparate != null) {
        _ctx.blendFuncSeparate(blendFuncSeparate[0], blendFuncSeparate[1], blendFuncSeparate[2], blendFuncSeparate[3]);
      }
    } else {
      _ctx.disable(gl.BLEND);
    }
  }

  void _setCullingState(bool enabled, int cullFace) {
    if (enabled) {
      _ctx.enable(gl.CULL_FACE);
      _ctx.cullFace(cullFace);
    } else {
      _ctx.disable(gl.CULL_FACE);
    }
  }

  void _setDepthBuffer(bool enabled, int depthFunc) {
    if (enabled) {
      _ctx.enable(gl.DEPTH_TEST);
      _ctx.depthFunc(depthFunc);
    } else {
      _ctx.disable(gl.DEPTH_TEST);
    }
  }

  void _setDepthWrite(bool enabled) {
    _ctx.depthMask(enabled);
  }
  
  void drawLines(int numVertices) {
    _ctx.drawArrays(gl.LINE_STRIP, 0, numVertices);
  }

  void drawTriangles(VertexBuffer indexBuffer, {int numTriangles, int offset: 0}) {
    if (_currentIndexBuffer != indexBuffer) {
      _currentIndexBuffer = indexBuffer;
      _ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer._bufferHandle);
    }
    if (numTriangles == null) numTriangles = indexBuffer._numVertices;
    _ctx.drawElements(gl.TRIANGLES, numTriangles * 3, gl.UNSIGNED_SHORT, offset);
  }
  
  /// ========== set uniforms ===============
  setMatrix4(gl.UniformLocation location, Matrix4 value) {
    _ctx.uniformMatrix4fv(location, false, value._elements);
  }
 
}




class DeviceCapabilities {
  final int maxTexturesImageUnits;
  final num maxTextureSize;
  final num maxCubemapTextureSize;
  final num maxRenderTextureSize;
  final bool standardDerivatives;
  final gl.CompressedTextureS3TC s3tc;
  final bool textureFloat;
  final gl.AngleInstancedArrays instancedArrays;
  gl.ExtTextureFilterAnisotropic textureAnisotropicFilterExtension;
  num maxAnisotropy;

  DeviceCapabilities(gl.RenderingContext ctx)
      : maxTexturesImageUnits = ctx.getParameter(gl.MAX_TEXTURE_IMAGE_UNITS),
        maxTextureSize = ctx.getParameter(gl.MAX_TEXTURE_SIZE),
        maxCubemapTextureSize = ctx.getParameter(gl.MAX_CUBE_MAP_TEXTURE_SIZE),
        maxRenderTextureSize = ctx.getParameter(gl.MAX_RENDERBUFFER_SIZE),
        standardDerivatives = (ctx.getExtension('OES_standard_derivatives') != null),
        s3tc = ctx.getExtension('WEBGL_compressed_texture_s3tc'),
        textureFloat = (ctx.getExtension('OES_texture_float') != null),
        textureAnisotropicFilterExtension = ctx.getExtension('EXT_texture_filter_anisotropic'),
        instancedArrays = ctx.getExtension('ANGLE_instanced_arrays') {

    if (textureAnisotropicFilterExtension == null) textureAnisotropicFilterExtension =
        ctx.getExtension('WEBKIT_EXT_texture_filter_anisotropic');

    if (textureAnisotropicFilterExtension == null) textureAnisotropicFilterExtension =
        ctx.getExtension('MOZ_EXT_texture_filter_anisotropic');

    if (textureAnisotropicFilterExtension == null) {
      maxAnisotropy = 0;
    } else {
      maxAnisotropy = ctx.getParameter(gl.ExtTextureFilterAnisotropic.MAX_TEXTURE_MAX_ANISOTROPY_EXT);
    }
  }
}