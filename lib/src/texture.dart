part of orange;



class TextureManager {
  static TextureManager _shared = new TextureManager._internal();
  
  factory TextureManager() {
    return _shared;
  }
  
  Map<String, gl.Texture> _textures;
  
  TextureManager._internal() {
    _textures = {};
  }
  
  Future<gl.Texture> load(gl.RenderingContext ctx, String url) {
    var completer = new Completer<gl.Texture>();
    if(_textures.containsKey(url)) {
      completer.complete(_textures[url]);
    } else {
      var texture = ctx.createTexture();
      var image = new html.ImageElement(src : url);
      image.onLoad.listen((_) {
        ctx.bindTexture(gl.TEXTURE_2D, texture);
        ctx.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, gl.RGBA, gl.UNSIGNED_BYTE, image);
        ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        ctx.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST);
        ctx.generateMipmap(gl.TEXTURE_2D);
        completer.complete(texture);
      }).
      onError(() {
        print("Failed to load image : $url");
        completer.completeError(texture);
      });
    }
  }
}