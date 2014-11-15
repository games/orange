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

  Texture load(String url, {String id, int target: gl.TEXTURE_2D, int type: gl.UNSIGNED_BYTE, int format: gl.RGBA,
      Sampler sampler, bool mipMaps: false, bool flip: false}) {

    id = or(id, url);

    var texture = new Texture._(id);
    texture.source = url;
    texture.target = target;
    texture.type = type;
    texture.format = format;
    texture.sampler = or(sampler, Sampler.defaultSampler);
    texture.flip = flip;
    texture.mipMapping = mipMaps;
    var image = new html.ImageElement(src: url);
    image.onLoad.listen((_) {
      texture.width = image.width;
      texture.height = image.height;
      var sampler = texture.sampler;
      if (texture.mipMapping || sampler.wrapS == gl.REPEAT || sampler.wrapT == gl.REPEAT) {
        image = _ensureImage(image);
      }
      Orange.instance.graphicsDevice.createTexture(texture, image);
      texture._ready = true;
    });

    return texture;
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
