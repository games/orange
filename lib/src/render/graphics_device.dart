// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
    _ctx = _renderingCanvas.getContext3d(preserveDrawingBuffer: true);
    if (_ctx == null) throw new Exception("WebGL is not supported");

    caps = new DeviceCapabilities(_ctx);
    // init


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

  void drawTriangles(VertexBuffer indexBuffer, {int numTriangles, int offset: 0}) {
    if (_currentIndexBuffer != indexBuffer) {
      _currentIndexBuffer = indexBuffer;
      _ctx.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer._bufferHandle);
    }
    if (numTriangles == null) numTriangles = indexBuffer._numVertices;
    _ctx.drawElements(gl.TRIANGLES, numTriangles * 3, gl.UNSIGNED_SHORT, offset);
  }


  gl.Buffer createBuffer() {
    return _ctx.createBuffer();
  }

  void deleteBuffer(VertexBuffer vertexBuffer) {
    _ctx.deleteBuffer(vertexBuffer._bufferHandle);
  }

  void uploaderBufferData(VertexBuffer vertexBuffer) {
    _ctx.bindBuffer(vertexBuffer._target, vertexBuffer._bufferHandle);
    _ctx.bufferDataTyped(vertexBuffer._target, vertexBuffer._data, vertexBuffer._usage);
  }

  void bindBuffer(VertexBuffer vertexBuffer) {
    _ctx.bindBuffer(vertexBuffer._target, vertexBuffer._bufferHandle);
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
