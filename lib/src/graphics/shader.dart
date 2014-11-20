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



class Shader extends Disposable {

  String name;
  List<Technique> techniques;
  Technique get technique => techniques.first;

  Shader(this.name) : techniques = [];

  @override
  void dispose() {
    techniques.forEach((t) => t.dispose());
  }

  // TODO remove
  static Shader defaultShader() {
    var effect = new Effect.load("packages/orange/src/shaders/default");

    var attributes = effect.attributes;
    attributes["aPosition"] = new EffectParameter(EffectBindings.POSITION);
    attributes["aNormal"] = new EffectParameter(EffectBindings.NORMAL);
    attributes["aUV"] = new EffectParameter(EffectBindings.TEXCOORD_0);

    var uniforms = effect.uniforms;
    uniforms["uViewMat"] = new EffectParameter(EffectBindings.VIEW);
    uniforms["uModelMat"] = new EffectParameter(EffectBindings.MODEL);
    uniforms["uProjectionMat"] = new EffectParameter(EffectBindings.PROJECTION);
    uniforms["uNormalMat"] = new EffectParameter(EffectBindings.MODEL_INVERSE_TRANSPOSE);
    uniforms["uDiffuseTexture"] = new EffectParameter(EffectBindings.DIFFUSE_TEXTURE);

    var pass = new Pass();
    pass.effect = effect;
    pass.renderState = new RenderState();

    var technique = new Technique("technique");
    technique.passes.add(pass);

    var shader = new Shader("default");
    shader.techniques.add(technique);
    return shader;
  }

  static Shader texturedShader() {
    var effect = new TexturedEffect();

    var pass = new Pass();
    pass.effect = effect;
    pass.renderState = new RenderState();

    var technique = new Technique("technique");
    technique.passes.add(pass);

    var shader = new Shader("textured");
    shader.techniques.add(technique);
    return shader;
  }

  static Shader skybox() {
    var pass = new Pass();
    pass.effect = new SkyboxEffect();
    pass.renderState = new RenderState();
    pass.renderState.cullFaceEnabled = false;
    
    var technique = new Technique("skybox");
    technique.passes.add(pass);

    var shader = new Shader("skybox");
    shader.techniques.add(technique);
    return shader;
  }
}

