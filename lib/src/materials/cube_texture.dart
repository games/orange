part of orange;




class CubeTexture extends Texture {

  static const extensions = const ["_px.jpg", "_py.jpg", "_pz.jpg", "_nx.jpg", "_ny.jpg", "_nz.jpg"];
  static const faces = const [gl.TEXTURE_CUBE_MAP_POSITIVE_X, gl.TEXTURE_CUBE_MAP_POSITIVE_Y, gl.TEXTURE_CUBE_MAP_POSITIVE_Z, gl.TEXTURE_CUBE_MAP_NEGATIVE_X, gl.TEXTURE_CUBE_MAP_NEGATIVE_Y, gl.TEXTURE_CUBE_MAP_NEGATIVE_Z];

  String root;
  
  factory CubeTexture(String root) {
    var key = "CubeTexture_${root}";
    if (Texture._texturesCache.containsKey(key)) {
      return Texture._texturesCache[key];
    }
    return new CubeTexture._(root);
  }

  CubeTexture._(this.root) {
    List<Future> futures = [];
    extensions.forEach((String ext) => futures.add(_loadImage(root + ext)));
    Future.wait(futures).then((List<html.ImageElement> images) {
      //TODO check max cubemap size
      var ctx = Orange.instance.graphicsDevice.ctx;
      var texture = ctx.createTexture();
      ctx.bindTexture(gl.TEXTURE_CUBE_MAP, texture);
      ctx.pixelStorei(gl.UNPACK_FLIP_Y_WEBGL, 0);
      for (var i = 0; i < faces.length; i++) {
        ctx.texImage2D(faces[i], 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, images[i]);
        width = images[i].width;
        height = images[i].height;
      }
      if (mipmap) ctx.generateMipmap(gl.TEXTURE_CUBE_MAP);
      ctx.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
      ctx.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_MIN_FILTER, mipmap ? gl.LINEAR_MIPMAP_LINEAR : gl.LINEAR);
      ctx.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
      ctx.texParameteri(gl.TEXTURE_CUBE_MAP, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
      ctx.bindTexture(gl.TEXTURE_CUBE_MAP, null);
      target = gl.TEXTURE_CUBE_MAP;
      data = texture;
      references = 1;
      _isCube = true;
      _textureMatrix = new Matrix4.identity();
      ready = true;
      Texture._texturesCache["CubeTexture_${root}"] = this;
    });
  }

  Future _loadImage(String url) {
    var completer = new Completer<html.ImageElement>();
    var img = new html.ImageElement(src: url);
    img.onLoad.listen((_) {
      completer.complete(img);
    });
    return completer.future;
  }
  
  @override
  Matrix4 get reflectionTextureMatrix  => _textureMatrix;

}
