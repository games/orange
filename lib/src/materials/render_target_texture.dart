part of orange;



abstract class Renderer {
  void render(Scene scene, List<Mesh> opaqueMeshes, {List<Mesh> alphaTestMeshes, List<Mesh> transparentMeshes});
}

class RenderTargetTexture extends Texture implements Renderer {
  gl.Framebuffer framebuffer;
  Renderer renderDelegate;

  RenderTargetTexture._();

  @override
  void render(Scene scene, List<Mesh> opaqueMeshes, {List<Mesh> alphaTestMeshes, List<Mesh> transparentMeshes}) {
    if (renderDelegate == null) return;
    var device = scene.device;
    device.bindFramebuffer(this);
    device.clear(scene.backgroundColor, backBuffer: true, depthStencil: true);
    renderDelegate.render(scene, opaqueMeshes, alphaTestMeshes: alphaTestMeshes, transparentMeshes: transparentMeshes);
    device.unbindFramebuffer();
  }

  static RenderTargetTexture create(GraphicsDevice device, int width, int height) {
    var ctx = device.ctx;
    var texture = new RenderTargetTexture._();
    texture.target = gl.TEXTURE_2D;
    texture.internalFormat = gl.RGBA;
    texture.format = gl.RGBA;
    texture.data = ctx.createTexture();
    texture.width = width;
    texture.height = height;
    texture.references = 1;
    ctx.activeTexture(gl.TEXTURE0);
    ctx.bindTexture(texture.target, texture.data);
    ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
    ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    ctx.texParameteri(texture.target, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
    ctx.texParameteri(texture.target, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    if (device.caps.textureFloat) {
      ctx.texImage2D(texture.target, 0, texture.internalFormat, width, height, 0, texture.format, gl.FLOAT, null);
    } else {
      ctx.texImage2D(texture.target, 0, texture.internalFormat, width, height, 0, texture.format, gl.UNSIGNED_BYTE, null);
    }

    // TODO create the depth buffer

    // framebuffer
    texture.framebuffer = ctx.createFramebuffer();
    ctx.bindFramebuffer(gl.FRAMEBUFFER, texture.framebuffer);
    ctx.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, texture.target, texture.data, 0);

    ctx.bindFramebuffer(gl.FRAMEBUFFER, null);
    ctx.bindTexture(texture.target, null);
    return texture;
  }
}










































