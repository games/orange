part of orange;



abstract class Renderer {
  void render(Scene scene, Matrix4 viewMatrix, Matrix4 viewProjectionMatrix, Matrix4 projectionMatrix, Vector3 eyePosition);
}

class RenderTargetTexture extends Texture implements Renderer {
  gl.Framebuffer framebuffer;
  gl.Renderbuffer depthBuffer;

  Renderer renderDelegate;

  RenderTargetTexture(GraphicsDevice device, int width, int height, {bool generateDepthBuffer: true}) {
    var ctx = device.ctx;
    target = gl.TEXTURE_2D;
    internalFormat = gl.RGBA;
    format = gl.RGBA;
    this.width = width;
    this.height = height;
    references = 1;

    data = ctx.createTexture();
    ctx.activeTexture(gl.TEXTURE0);
    ctx.bindTexture(target, data);
    ctx.texParameteri(target, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    ctx.texParameteri(target, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    ctx.texParameteri(target, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    ctx.texParameteri(target, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    if (device.caps.textureFloat) {
      ctx.texImage2DTyped(target, 0, internalFormat, width, height, 0, format, gl.FLOAT, null);
    } else {
      ctx.texImage2DTyped(target, 0, internalFormat, width, height, 0, format, gl.UNSIGNED_BYTE, null);
    }

    // renderbuffer
    if (generateDepthBuffer) {
      depthBuffer = ctx.createRenderbuffer();
      ctx.bindRenderbuffer(gl.RENDERBUFFER, depthBuffer);
      ctx.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT16, width, height);
    }

    // framebuffer
    framebuffer = ctx.createFramebuffer();
    ctx.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
    ctx.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, target, data, 0);

    ctx.bindFramebuffer(gl.FRAMEBUFFER, null);
    ctx.bindRenderbuffer(gl.RENDERBUFFER, null);
    ctx.bindTexture(target, null);
  }

  @override
  void render(Scene scene, Matrix4 viewMatrix, Matrix4 viewProjectionMatrix, Matrix4 projectionMatrix, Vector3 eyePosition) {
    var device = scene.graphicsDevice;
    device.bindFramebuffer(this);
    device.clear(new Color(0, 0, 0), backBuffer: true, depthStencil: true);
    device.ctx.viewport(0, 0, width, height);
    if(renderDelegate == null) renderDelegate = Orange.instance._renderGroup;
    renderDelegate.render(scene,  viewMatrix,  viewProjectionMatrix,  projectionMatrix,  eyePosition);
    device.unbindFramebuffer();
  }
}

































