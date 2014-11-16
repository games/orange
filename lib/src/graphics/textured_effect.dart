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


/// from https://github.com/BabylonJS/Babylon.js
/// thanks to David Catuhe
class TexturedEffect extends Effect {

  Color3 ambientColor;
  Color4 diffuseColor = new Color4.all(1.0);
  Color4 specularColor;
  Color3 emissiveColor;
  double shininess;
  double alpha = 1.0;
  double specularPower = 1.0;

  Texture bumpTexture;
  Texture ambientTexture;
  Texture opacityTexture;
  Texture emissiveTexture;
  Texture specularTexture;

  TexturedEffect() : super.load("packages/orange/src/shaders/textured");

  @override
  bool prepare(EffectContext context) {
    if (_ready) return false;

    attributes["position"] = new EffectParameter(Semantices.POSITION);
    attributes["normal"] = new EffectParameter(Semantices.NORMAL);
    attributes["uv"] = new EffectParameter(Semantices.TEXCOORD_0);

    uniforms["view"] = new EffectParameter(Semantices.VIEW);
    uniforms["viewProjection"] = new EffectParameter(Semantices.VIEW_PROJECTION);
    uniforms["world"] = new EffectParameter(Semantices.MODEL);

    // diffuse
    uniforms["diffuseMatrix"] = new EffectParameter(Semantices.MATRIX4_IDENTITY);
    uniforms["diffuseSampler"] = new EffectParameter(Semantices.DIFFUSE_TEXTURE);
    uniforms["vDiffuseInfos"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      graphics.setFloat2(context.parameter.location, 0.0, 1.0);
    });

    // colors
    uniforms["vAmbientColor"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
        if(ambientColor != null) graphics.setColor3(context.parameter.location, ambientColor);
    });
    uniforms["vDiffuseColor"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      if(diffuseColor != null) graphics.setColor4(context.parameter.location, diffuseColor);
    });
    uniforms["vSpecularColor"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      if(specularColor != null) graphics.setColor4(context.parameter.location, specularColor);
    });
    uniforms["vEmissiveColor"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      if(emissiveColor != null) graphics.setColor3(context.parameter.location, emissiveColor);
    });

    uniforms["vEyePosition"] = new EffectParameter(Semantices.EYE_POSITION);

    var defines = [];
    if (context.material.mainTexture != null) {
      defines.add("DIFFUSE");
      defines.add("UV1");
    }

    _commonSrc = Effect.jointAsDefines(defines);

    return true;
  }
}




