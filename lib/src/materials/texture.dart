part of orange;


var defaultSampler = new Sampler();


class Texture {
  gl.Texture data;
  int format;
  int internalFormat;
  int target;
  int references = 0;
  int width;
  int height;
}


class TextureManager {
  static TextureManager _shared = new TextureManager._internal();

  factory TextureManager() {
    return _shared;
  }

  Map<String, Texture> _textures;

  TextureManager._internal() {
    _textures = {};
  }

  Future<Texture> load(gl.RenderingContext ctx, Map descripton) {
    var completer = new Completer<Texture>();
    if (descripton == null) {
      completer.complete(null);
    } else {
      var url = descripton["path"];
      if (_textures.containsKey(url)) {
        completer.complete(_textures[url]);
      } else {
        var sampler = or(descripton["sampler"], defaultSampler);
        var image = new html.ImageElement(src: url);
        image.onLoad.listen((_) {
          var texture = new Texture();
          texture.target = or(descripton["target"], gl.TEXTURE_2D);
          texture.internalFormat = or(descripton["internalFormat"], gl.RGBA);
          texture.format = or(descripton["format"], gl.RGBA);
          texture.data = ctx.createTexture();
          texture.width = image.width;
          texture.height = image.height;
          var usesMipMaps = ((sampler.minFilter == gl.NEAREST_MIPMAP_NEAREST) || (sampler.minFilter == gl.LINEAR_MIPMAP_NEAREST) || (sampler.minFilter == gl.NEAREST_MIPMAP_LINEAR) ||
              (sampler.minFilter == gl.LINEAR_MIPMAP_LINEAR));
          if (usesMipMaps || sampler.wrapS == gl.REPEAT || sampler.wrapT == gl.REPEAT) {
            image = _ensureImage(image);
          }
          ctx.bindTexture(texture.target, texture.data);
          ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_S, sampler.wrapS);
          ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_T, sampler.wrapT);
          ctx.texParameteri(texture.target, gl.TEXTURE_MIN_FILTER, sampler.minFilter);
          ctx.texParameteri(texture.target, gl.TEXTURE_MAG_FILTER, sampler.magFilter);
          ctx.texImage2D(texture.target, 0, texture.internalFormat, texture.format, gl.UNSIGNED_BYTE, image);
          if (usesMipMaps) {
            ctx.generateMipmap(texture.target);
          }
          ctx.bindTexture(texture.target, null);
          _textures[url] = texture;
          completer.complete(texture);
        }).onError(() {
          print("Failed to load image : $url");
          completer.completeError(null);
        });
      }
    }
    return completer.future;
  }

  _ensureImage(html.ImageElement source) {
    var img = source;
    var shouldResize = false;
    var width = source.width;
    if (!_isPowerOfTwo(width)) {
      width = _nextHighestPowerOfTwo(width);
      shouldResize = true;
    }
    var height = source.height;
    if (!_isPowerOfTwo(height)) {
      height = _nextHighestPowerOfTwo(height);
      shouldResize = true;
    }
    if (shouldResize) {
      var canvas = new html.CanvasElement();
      canvas.width = width;
      canvas.height = height;
      var graphics = canvas.context2D;
      graphics.drawImageScaled(source, 0, 0, width, height);
      img = canvas;
    }
    return img;
  }

  _isPowerOfTwo(int x) {
    return (x & (x - 1)) == 0;
  }

  _nextHighestPowerOfTwo(int x) {
    --x;
    for (var i = 1; i < 32; i <<= 1) {
      x = x | x >> i;
    }
    return x + 1;
  }
}
