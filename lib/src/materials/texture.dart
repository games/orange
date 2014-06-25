part of orange;


var defaultSampler = new Sampler();


class Texture {
  static int NEAREST_SAMPLINGMODE = 1;
  static int BILINEAR_SAMPLINGMODE = 2;
  static int TRILINEAR_SAMPLINGMODE = 3;

  static int EXPLICIT_MODE = 0;
  static int SPHERICAL_MODE = 1;
  static int PLANAR_MODE = 2;
  static int CUBIC_MODE = 3;
  static int PROJECTION_MODE = 4;
  static int SKYBOX_MODE = 5;

  static int CLAMP_ADDRESSMODE = 0;
  static int WRAP_ADDRESSMODE = 1;
  static int MIRROR_ADDRESSMODE = 2;


  String source;
  gl.Texture data;
  int format;
  int internalFormat;
  int target;
  int type;
  int references = 0;
  int width;
  int height;
  Sampler sampler;
  bool ready = false;

  bool getAlphaFromRGB = false;
  bool isCube = false;
  double coordinatesIndex = 0.0;
  int coordinatesMode = SPHERICAL_MODE;
  double level = 1.0;

  // TODO
  void dispose() {
    unload(source);
  }

  static Map<String, Texture> _texturesCache = {};

  // TODO use named parameters
  static Texture load(gl.RenderingContext ctx, Map descripton) {
    var url = descripton["path"];
    if (_texturesCache.containsKey(url)) {
      return _texturesCache[url];
    } else {
      var texture = new Texture();
      texture.source = url;
      texture.target = or(descripton["target"], gl.TEXTURE_2D);
      texture.type = or(descripton["type"], gl.UNSIGNED_BYTE);
      texture.internalFormat = or(descripton["internalFormat"], gl.RGBA);
      texture.format = or(descripton["format"], gl.RGBA);
      texture.sampler = or(descripton["sampler"], defaultSampler);
      var flip = or(descripton["FLIP"], false);
      var image = new html.ImageElement(src: url);
      image.onLoad.listen((_) {
        texture.data = ctx.createTexture();
        var sampler = texture.sampler;
        texture.width = image.width;
        texture.height = image.height;
        var usesMipMaps = ((sampler.minFilter == gl.NEAREST_MIPMAP_NEAREST) || (sampler.minFilter == gl.LINEAR_MIPMAP_NEAREST) || (sampler.minFilter == gl.NEAREST_MIPMAP_LINEAR) || (sampler.minFilter
            == gl.LINEAR_MIPMAP_LINEAR));
        if (usesMipMaps || sampler.wrapS == gl.REPEAT || sampler.wrapT == gl.REPEAT) {
          image = _ensureImage(image);
        }
        ctx.bindTexture(texture.target, texture.data);
        if (flip) ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
        ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_S, sampler.wrapS);
        ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_T, sampler.wrapT);
        ctx.texParameteri(texture.target, gl.TEXTURE_MIN_FILTER, sampler.minFilter);
        ctx.texParameteri(texture.target, gl.TEXTURE_MAG_FILTER, sampler.magFilter);
        ctx.texImage2D(texture.target, 0, texture.internalFormat, texture.format, texture.type, image);
        if (usesMipMaps) {
          ctx.generateMipmap(texture.target);
        }
        ctx.bindTexture(texture.target, null);
        texture.ready = true;
        _texturesCache[url] = texture;
      });
      return texture;
    }
  }

  // TODO not implement yet
  static void unload(String url) {
    if (_texturesCache.containsKey(url)) {

    }
  }

  static _ensureImage(html.ImageElement source) {
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

  static bool _isPowerOfTwo(int x) {
    return (x & (x - 1)) == 0;
  }

  static int _nextHighestPowerOfTwo(int x) {
    --x;
    for (var i = 1; i < 32; i <<= 1) {
      x = x | x >> i;
    }
    return x + 1;
  }
}

/**
 * use Texture.load(); 
 **/
@deprecated
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
          texture.type = or(descripton["type"], gl.UNSIGNED_BYTE);
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
          ctx.texImage2D(texture.target, 0, texture.internalFormat, texture.format, texture.type, image);
          if (usesMipMaps) {
            ctx.generateMipmap(texture.target);
          }
          ctx.bindTexture(texture.target, null);
          texture.ready = true;
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
