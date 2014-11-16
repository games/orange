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

  update(String name, dynamic location, int type, [EffectBinding binding = null]) {
    var param = _parameters.containsKey(name) ? _parameters[name] : new EffectParameter(EffectBindings.NONE);
    param.name = name;
    param.location = location;
    param.type = type;
    if (binding != null) param.binding = binding;
    _parameters[name] = param;
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
  EffectBinding binding;

  EffectParameter(this.binding);

  bind(GraphicsDevice graphics, EffectContext context) {
    context.parameter = this;
    binding(graphics, context);
  }

  @override
  String toString() => "${name}: ${location}";
}


class EffectBindings {
  static const EffectBinding NONE = _noneBinding;
  static const EffectBinding MATRIX4_IDENTITY = _matrix4IdentityBinding;

  // attributes
  static const EffectBinding POSITION = _positionBinding;
  static const EffectBinding TEXCOORD_0 = _texCoordBinding;
  static const EffectBinding TEXCOORD_1 = _texCoord2Binding;
  static const EffectBinding NORMAL = _normalBinding;
  static const EffectBinding INDEX = _indexBinding;
  static const EffectBinding JOINT_WEIGHTS = _joinWeightsBinding;
  static const EffectBinding JOINTS = _joinsBinding;
  static const EffectBinding JOINT_MATRICES = _joinsMatricesBinding;

  // uniforms
  static const EffectBinding MODEL = _modelBinding;
  static const EffectBinding VIEW = _viewBinding;
  static const EffectBinding PROJECTION = _projectionBinding;
  static const EffectBinding VIEW_PROJECTION = _viewProjectionBinding;
  static const EffectBinding WORLD_VIEW_PROJECTION = _worldViewProjectionBinding;
  static const EffectBinding MODEL_INVERSE_TRANSPOSE = _modelInverseTranspose;
  static const EffectBinding EYE_POSITION = _eyePositionBinding;

  static const EffectBinding DIFFUSE_TEXTURE = _diffuseTextureBinding;
}



typedef void EffectBinding(GraphicsDevice graphics, EffectContext context);

void _uploadEnableBuffer(GraphicsDevice graphics, EffectParameter parameter, VertexBuffer buffer) {
  buffer.upload(graphics);
  buffer.enable(graphics, parameter);
}

_noneBinding(GraphicsDevice graphics, EffectContext context) {}

_positionBinding(GraphicsDevice graphics, EffectContext context) =>
    _uploadEnableBuffer(graphics, context.parameter, context.mesh.vertexBuffer);

_texCoordBinding(GraphicsDevice graphics, EffectContext context) =>
    _uploadEnableBuffer(graphics, context.parameter, context.mesh.texCoordsBuffer);

_texCoord2Binding(GraphicsDevice graphics, EffectContext context) =>
    _uploadEnableBuffer(graphics, context.parameter, context.mesh.texCoords2Buffer);

_normalBinding(GraphicsDevice graphics, EffectContext context) =>
    _uploadEnableBuffer(graphics, context.parameter, context.mesh.normalBuffer);

_indexBinding(GraphicsDevice graphics, EffectContext context) =>
    _uploadEnableBuffer(graphics, context.parameter, context.mesh.indexBuffer);

_joinWeightsBinding(GraphicsDevice graphics, EffectContext context) {
  // TODO
}

_joinsBinding(GraphicsDevice graphics, EffectContext context) {
  // TODO
}

_joinsMatricesBinding(GraphicsDevice graphics, EffectContext context) {
  // TODO
}

_matrix4IdentityBinding(GraphicsDevice graphics, EffectContext context) =>
    graphics.setMatrix4(context.parameter.location, new Matrix4.identity());

_modelBinding(GraphicsDevice graphics, EffectContext context) =>
    graphics.setMatrix4(context.parameter.location, context.target.transform.worldMatrix);

_viewBinding(GraphicsDevice graphics, EffectContext context) =>
    graphics.setMatrix4(context.parameter.location, context.camera.view);

_projectionBinding(GraphicsDevice graphics, EffectContext context) =>
    graphics.setMatrix4(context.parameter.location, context.camera.projection);

_viewProjectionBinding(GraphicsDevice graphics, EffectContext context) =>
    graphics.setMatrix4(context.parameter.location, context.camera.viewProjection);

_worldViewProjectionBinding(GraphicsDevice graphics, EffectContext context) =>
    graphics.setMatrix4(context.parameter.location, context.camera.viewProjection * context.target.transform.worldMatrix);

_modelInverseTranspose(GraphicsDevice graphics, EffectContext context) {
  var mat3 = context.target.transform.worldMatrix.inverseMatrix3();
  if (mat3 != null) graphics.setMatrix3(context.parameter.location, mat3.transpose());
}

_eyePositionBinding(GraphicsDevice graphics, EffectContext context) =>
    graphics.setVector3(context.parameter.location, context.camera._target.transform.worldPosition);

_diffuseTextureBinding(GraphicsDevice graphics, EffectContext context) {
  var channel = context.pass.effect.samplers.indexOf(context.parameter.name);
  graphics.bindTexture(context.material.mainTexture, channel);
}
