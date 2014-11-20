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



class ResourceManager extends Disposable {

  Map<String, Texture> _textures = {};

  Texture getTexture(String id) => _textures[id];

  Texture loadTexture(String url, {String id, int type: gl.UNSIGNED_BYTE, int format: gl.RGBA, Sampler sampler,
      bool mipMaps: false, bool flip: false}) {

    id = or(id, url);
    if (_textures.containsKey(id)) return _textures[id];

    var texture =
        new TextureLoader().load(url, id: id, type: type, format: format, sampler: sampler, mipMaps: mipMaps, flip: flip);
    _textures[texture.id] = texture;

    return texture;
  }

  Texture loadCubemapTexture(String url, {String id, int type: gl.UNSIGNED_BYTE, int format: gl.RGBA, Sampler sampler,
      bool mipMaps: false}) {
    id = or(id, url);
    if (_textures.containsKey(id)) return _textures[id];

    var texture =
        new TextureLoader().loadCubemap(url, id: id, type: type, format: format, sampler: sampler, mipMaps: mipMaps);
    _textures[texture.id] = texture;

    return texture;
  }

  @override
  void dispose() {
    _textures.forEach((k, t) => t.dispose());
  }
}
