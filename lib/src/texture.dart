part of orange;


class Texture {
  Sampler sampler;
  String path;
  html.ImageElement source;
  int format;
  int internalFormat;
  int target;
  
  bool get ready => texture != null;
  
  gl.Texture texture;
  
  setup(gl.RenderingContext ctx) {
    if(source == null) {
      source = new html.ImageElement(src : path);
      source.onLoad.listen((_) => _createTexture(ctx));
    }
  }
  
  _createTexture(gl.RenderingContext ctx) {
    var usesMipMaps = ((sampler.minFilter == gl.NEAREST_MIPMAP_NEAREST) ||
        (sampler.minFilter == gl.LINEAR_MIPMAP_NEAREST) ||
        (sampler.minFilter == gl.NEAREST_MIPMAP_LINEAR) ||
        (sampler.minFilter == gl.LINEAR_MIPMAP_LINEAR));
    
    var image = source;
    if(usesMipMaps || sampler.wrapS == gl.REPEAT || sampler.wrapT == gl.REPEAT) {
      image = _ensureImage(source);
    }
    
    texture = ctx.createTexture();
    ctx.bindTexture(target, texture);
    ctx.texParameteri(target, gl.TEXTURE_WRAP_S, sampler.wrapS);
    ctx.texParameteri(target, gl.TEXTURE_WRAP_T, sampler.wrapT);
    ctx.texParameteri(target, gl.TEXTURE_MIN_FILTER, sampler.minFilter);
    ctx.texParameteri(target, gl.TEXTURE_MAG_FILTER, sampler.magFilter);
    ctx.texImage2D(target, 0, internalFormat, format, gl.UNSIGNED_BYTE, image);
    if(usesMipMaps) {
      ctx.generateMipmap(target);
    }
    ctx.bindTexture(target, null);
  }
  
  _ensureImage(html.ImageElement source) {
    var img = source;
    var shouldResize = false;
    var width = source.width;
    if(!_isPowerOfTwo(width)) {
      width = _nextHighestPowerOfTwo(width);
      shouldResize = true;
    }
    var height = source.height;
    if(!_isPowerOfTwo(height)) {
      height = _nextHighestPowerOfTwo(height);
      shouldResize = true;
    }
    if(shouldResize) {
      var canvas = new html.CanvasElement();
      canvas.width = width;
      canvas.height = height;
      var graphics = canvas.context2D;
      graphics.drawImageScaled(source, 0, 0, width, height);
      img = canvas;
    }
    return img;
  }
}

_isPowerOfTwo(int x) {
  return (x & (x - 1)) == 0;
}

_nextHighestPowerOfTwo(int x) {
  --x;
  for(var i = 1; i < 32; i <<= 1) {
    x = x | x >> i;
  }
  return x + 1;
}

















