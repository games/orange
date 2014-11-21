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

class TextureLoader {

  static const extensions = const ["_px.jpg", "_py.jpg", "_pz.jpg", "_nx.jpg", "_ny.jpg", "_nz.jpg"];

  Texture load(String url, {String id, int type: gl.UNSIGNED_BYTE, int format: gl.RGBA, Sampler sampler, bool mipMaps:
      false, bool flip: false}) {
    return _loadInternal(url, or(id, url), gl.TEXTURE_2D, type, format, sampler, mipMaps, flip);
  }

  //TODO check max cubemap size
  Texture loadCubemap(String url, {String id, int type: gl.UNSIGNED_BYTE, int format: gl.RGBA, Sampler sampler,
      bool mipMaps: false}) {
    return _loadInternal(url, or(id, url), gl.TEXTURE_CUBE_MAP, type, format, sampler, mipMaps, false);
  }

  Texture _loadInternal(String url, String id, int target, int type, int format, Sampler sampler, bool mipMaps,
      bool flip) {

    var texture = new Texture._(id);
    texture.source = url;
    texture.target = target;
    texture.type = type;
    texture.format = format;
    texture.flip = flip;
    texture.mipMapping = mipMaps;

    if (target == gl.TEXTURE_2D) {
      texture.sampler = or(sampler, Sampler.defaultSampler);
      var image = new html.ImageElement(src: url);
      image.onLoad.listen((_) {
        var sampler = texture.sampler;
        if (texture.mipMapping || sampler.wrapS == gl.REPEAT || sampler.wrapT == gl.REPEAT) {
          image = _ensureImage(image);
        }
        _createTexture(texture, [image]);
      });
    } else if (target == gl.TEXTURE_CUBE_MAP) {
      if (texture.sampler == null) {
        texture.sampler = new Sampler()
            ..wrapS = gl.CLAMP_TO_EDGE
            ..wrapT = gl.CLAMP_TO_EDGE
            ..minFilter = texture.mipMapping ? gl.LINEAR_MIPMAP_LINEAR : gl.LINEAR;
      }
      List<Future> futures = [];
      extensions.forEach((String ext) => futures.add(_loadImage(url + ext)));
      Future.wait(futures).then((List<html.ImageElement> images) {
        _createTexture(texture, images);
      });
    }
    return texture;
  }

  void _createTexture(Texture texture, List<html.ImageElement> images) {
    var img = images.first;
    texture.width = img.width;
    texture.height = img.height;
    Orange.instance.graphicsDevice.createTexture(texture, images);
    texture._ready = true;
  }

  Future _loadImage(String url) {
    var completer = new Completer<html.ImageElement>();
    var img = new html.ImageElement(src: url);
    img.onLoad.listen((_) {
      completer.complete(img);
    });
    img.onError.listen((e){
      print(e);
    });
    return completer.future;
  }

  _ensureImage(html.ImageElement source) {
    var result = source;
    var shouldResize = false;
    var width = source.width;
    if (!isPowerOfTwo(width)) {
      width = nextHighestPowerOfTwo(width);
      shouldResize = true;
    }
    var height = source.height;
    if (!isPowerOfTwo(height)) {
      height = nextHighestPowerOfTwo(height);
      shouldResize = true;
    }
    if (shouldResize) {
      var canvas = new html.CanvasElement();
      canvas.width = width;
      canvas.height = height;
      var graphics = canvas.context2D;
      graphics.drawImageScaled(source, 0, 0, width, height);
      result = canvas;
    }
    return result;
  }

}
