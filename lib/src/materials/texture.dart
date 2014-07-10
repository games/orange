part of orange;


var defaultSampler = new Sampler();


class Texture implements Disposable {
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

  String name;
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

  bool hasAlpha = false;
  bool getAlphaFromRGB = false;
  bool _isCube = false;
  bool mipmap = true;
  bool flip = false;
  int coordinatesIndex = 0;
  int coordinatesMode = SPHERICAL_MODE;
  double level = 1.0;
  double uScale = 1.0;
  double vScale = 1.0;
  double uOffset = 0.0;
  double vOffset = 0.0;
  double uAng = 0.0;
  double vAng = 0.0;
  double wAng = 0.0;
  double wrapU = 0.0;
  double wrapV = 0.0;

  // TODO needs to reset dirty when other parameters have chagned
  bool _dirty = true;
  Matrix4 _textureMatrix;
  Matrix4 _rowGenerationMatrix;
  Matrix4 _projectionModeMatrix;
  Vector4 _t0, _t1, _t2;

  // TODO
  Matrix4 get textureMatrix {
    if (!_dirty && _textureMatrix != null) return _textureMatrix;
    _dirty = false;

    if (_textureMatrix == null) {
      _textureMatrix = new Matrix4.zero();
      _rowGenerationMatrix = new Matrix4.identity();
      _t0 = new Vector4.zero();
      _t1 = new Vector4.zero();
      _t2 = new Vector4.zero();
    }
    _prepareRowForTextureGeneration(0.0, 0.0, 0.0, _t0);
    _prepareRowForTextureGeneration(1.0, 0.0, 0.0, _t1);
    _prepareRowForTextureGeneration(0.0, 1.0, 0.0, _t2);

    _t1.sub(_t0);
    _t2.sub(_t0);
    _textureMatrix.setIdentity();
    _textureMatrix.setColumn(0, _t1);
    _textureMatrix.setColumn(1, _t2);
    _textureMatrix.setColumn(2, _t0);
    return _textureMatrix;
  }

  void _prepareRowForTextureGeneration(double x, double y, double z, Vector4 t) {
    x -= uOffset + 0.5;
    y -= vOffset + 0.5;
    z -= 0.5;
    var t1 = _rowGenerationMatrix * new Vector4(x, y, z, 0.0);
    t1.x *= uScale;
    t1.y *= vScale;
    t1.x += 0.5;
    t1.y += 0.5;
    t1.z += 0.5;
    t1.copyInto(t);
  }

  // TODO
  Matrix4 get reflectionTextureMatrix {
    if (!_dirty && _textureMatrix != null) return _textureMatrix;
    _dirty = false;

    if (_textureMatrix == null) {
      _textureMatrix = new Matrix4.zero();
      _projectionModeMatrix = new Matrix4.zero();
    }
    if (coordinatesMode == SPHERICAL_MODE) {
      _textureMatrix.setIdentity();
      _textureMatrix[0] = -0.5 * uScale;
      _textureMatrix[5] = -0.5 * vScale;
      _textureMatrix[12] = 0.5 + uOffset;
      _textureMatrix[13] = 0.5 + vOffset;
    } else if (coordinatesMode == PLANAR_MODE) {
      _textureMatrix.setIdentity();
      _textureMatrix[0] = uScale;
      _textureMatrix[5] = vScale;
      _textureMatrix[12] = uOffset;
      _textureMatrix[13] = vOffset;
    } else if (coordinatesMode == PROJECTION_MODE) {
      _projectionModeMatrix.setIdentity();
      _projectionModeMatrix[0] = 0.5;
      _projectionModeMatrix[5] = -0.5;
      _projectionModeMatrix[10] = 0.0;
      _projectionModeMatrix[12] = 0.5;
      _projectionModeMatrix[13] = 0.5;
      _projectionModeMatrix[14] = 1.0;
      _projectionModeMatrix[15] = 1.0;
      _textureMatrix = Orange.instance.scene.camera.projectionMatrix * _projectionModeMatrix;
    } else {
      _textureMatrix.setIdentity();
    }
    return _textureMatrix;

  }

  void dispose() {
    references--;
    if (references <= 0) {
      _texturesCache.remove(source);
      Orange.instance.graphicsDevice.ctx.deleteTexture(data);
    }
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
      texture.flip = or(descripton["flip"], false);
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
        if (texture.flip) {
          ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 1);
        } else {
          ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 0);
        }
        ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_S, sampler.wrapS);
        ctx.texParameteri(texture.target, gl.TEXTURE_WRAP_T, sampler.wrapT);
        ctx.texParameteri(texture.target, gl.TEXTURE_MIN_FILTER, sampler.minFilter);
        ctx.texParameteri(texture.target, gl.TEXTURE_MAG_FILTER, sampler.magFilter);
        if (image is html.CanvasElement) {
          ctx.texImage2DCanvas(texture.target, 0, texture.internalFormat, texture.format, texture.type, image);
        } else {
          ctx.texImage2DImage(texture.target, 0, texture.internalFormat, texture.format, texture.type, image);
        }
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
