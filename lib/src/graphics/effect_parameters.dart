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



class EffectParameters {

  Map<String, EffectParameter> _parameters;
  EffectParameters() : _parameters = {};

  add(EffectParameter parameter) => _parameters[parameter.name] = parameter;

  set(String name, dynamic location, int type) {
    if (_parameters.containsKey(name)) {
      var param = _parameters[name];
      param.name = name;
      param.location = location;
      param.type = type;
    } else {
      add(new EffectParameter(name, location, type));
    }
  }

  void forEach(void handler(String name, EffectParameter parameter)) {
    _parameters.forEach(handler);
  }

  EffectParameter operator [](String name) => _parameters[name];

  void operator []=(String name, EffectParameter parameter) {
    _parameters[name] = parameter;
  }
}


class EffectParameter {
  String name;
  dynamic location;
  int type;
  Semantices semantic;

  EffectParameter(this.name, this.location, this.type);
  
  EffectParameter.semantics(this.semantic);

  bind(GraphicsDevice graphics, DataProvider provider) => semantic.bind(graphics, this, provider);

  @override
  String toString() => "${name}: ${location}";
}


class Semantices {
  // attributes
  static const Semantices POSITION = const Semantices(_positionBinding);
  static const Semantices TEXCOORD_0 = const Semantices(_texCoordBinding);
  static const Semantices TEXCOORD_1 = const Semantices(_texCoord2Binding);
  static const Semantices NORMAL = const Semantices(_normalBinding);
  static const Semantices INDEX = const Semantices(_indexBinding);
  static const Semantices JOINT_WEIGHTS = const Semantices(_joinWeightsBinding);
  static const Semantices JOINTS = const Semantices(_joinsBinding);
  static const Semantices JOINT_MATRICES = const Semantices(_joinsMatricesBinding);

  // uniforms
  static const Semantices MODEL = const Semantices(_modelBinding);
  static const Semantices VIEW = const Semantices(_viewBinding);
  static const Semantices PROJECTION = const Semantices(_projectionBinding);
  static const Semantices VIEW_PROJECTION = const Semantices(_viewProjectionBinding);
  static const Semantices WORLD_VIEW_PROJECTION = const Semantices(_worldViewProjectionBinding);
  static const Semantices MODEL_INVERSE_TRANSPOSE = const Semantices(_modelInverseTranspose);
  
  static const Semantices DIFFUSE_TEXTURE = const Semantices(_diffuseTextureBinding);

  final _Binding binding;
  const Semantices(this.binding);

  void bind(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
      binding(graphics, parameter, provider);
}


class DataProvider {
  Camera camera;
  Node target;
  Mesh mesh;
  Material material;
  Pass pass;
}


typedef void _Binding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider);

void _uploadEnableBuffer(GraphicsDevice graphics, EffectParameter parameter, VertexBuffer buffer) {
  buffer.upload(graphics);
  buffer.enable(graphics, parameter);
}

_positionBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    _uploadEnableBuffer(graphics, parameter, provider.mesh.vertexBuffer);

_texCoordBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    _uploadEnableBuffer(graphics, parameter, provider.mesh.texCoordsBuffer);

_texCoord2Binding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    _uploadEnableBuffer(graphics, parameter, provider.mesh.texCoords2Buffer);

_normalBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    _uploadEnableBuffer(graphics, parameter, provider.mesh.normalBuffer);

_indexBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    _uploadEnableBuffer(graphics, parameter, provider.mesh.indexBuffer);

_joinWeightsBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) {
  // TODO
}

_joinsBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) {
  // TODO
}

_joinsMatricesBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) {
  // TODO
}

_modelBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    graphics.setMatrix4(parameter.location, provider.target.transform.worldMatrix);

_viewBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    graphics.setMatrix4(parameter.location, provider.camera.view);

_projectionBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    graphics.setMatrix4(parameter.location, provider.camera.projection);

_viewProjectionBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    graphics.setMatrix4(parameter.location, provider.camera.viewProjection);

_worldViewProjectionBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) =>
    graphics.setMatrix4(parameter.location, provider.camera.viewProjection * provider.target.transform.worldMatrix);

_modelInverseTranspose(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) {
    var mat3 = provider.target.transform.worldMatrix.inverseMatrix3(); 
    if(mat3 != null)
      graphics.setMatrix3(parameter.location, mat3.transpose());
}
    
    

_diffuseTextureBinding(GraphicsDevice graphics, EffectParameter parameter, DataProvider provider) {
    var channel = provider.pass.effect.samplers.indexOf(parameter.name);
    graphics.bindTexture(provider.material.mainTexture, channel);
}
    
