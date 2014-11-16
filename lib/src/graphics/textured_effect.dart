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


/// shader code is from https://github.com/BabylonJS/Babylon.js
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
    if (_ready || _vertSrc == null || _fragSrc == null) return false;

    attributes["position"] = new EffectParameter(EffectBindings.POSITION);
    attributes["normal"] = new EffectParameter(EffectBindings.NORMAL);
    attributes["uv"] = new EffectParameter(EffectBindings.TEXCOORD_0);

    uniforms["view"] = new EffectParameter(EffectBindings.VIEW);
    uniforms["viewProjection"] = new EffectParameter(EffectBindings.VIEW_PROJECTION);
    uniforms["world"] = new EffectParameter(EffectBindings.MODEL);

    // diffuse
    uniforms["diffuseMatrix"] = new EffectParameter(EffectBindings.MATRIX4_IDENTITY);
    uniforms["diffuseSampler"] = new EffectParameter(EffectBindings.DIFFUSE_TEXTURE);
    uniforms["vDiffuseInfos"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      graphics.setFloat2(context.parameter.location, 0.0, 1.0);
    });

    // colors
    uniforms["vAmbientColor"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      if (ambientColor != null) graphics.setColor3(context.parameter.location, ambientColor);
    });
    uniforms["vDiffuseColor"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      if (diffuseColor != null) graphics.setColor4(context.parameter.location, diffuseColor);
    });
    uniforms["vSpecularColor"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      if (specularColor != null) graphics.setColor4(context.parameter.location, specularColor);
    });
    uniforms["vEmissiveColor"] = new EffectParameter((GraphicsDevice graphics, EffectContext context) {
      if (emissiveColor != null) graphics.setColor3(context.parameter.location, emissiveColor);
    });

    uniforms["vEyePosition"] = new EffectParameter(EffectBindings.EYE_POSITION);

    var defines = [];
    if (context.material.mainTexture != null) {
      defines.add("DIFFUSE");
      defines.add("UV1");
    }
    var lights = context.getLights();
    for (var i = 0; i < lights.length; i++) {
      defines.add("LIGHT$i");
      var light = lights[i];
      switch (light.light.type) {
        case Light.DIRECTIONAL:
          defines.add("POINTDIRLIGHT$i");
          uniforms["vLightData$i"] = new EffectParameter(_directionalLightDataBinding(light, i));
          break;
        case Light.POINT:
          defines.add("POINTDIRLIGHT$i");
          uniforms["vLightData$i"] = new EffectParameter(_pointLightDataBinding(light, i));
          break;
        case Light.SPOT:
          defines.add("SPOTLIGHT$i");
          uniforms["vLightData$i"] = new EffectParameter(_spotLightDataBinding(light, i));
          uniforms["vLightDirection$i"] = new EffectParameter(_spotLightDirectionBinding(light, i));
          break;
        case Light.HEMISPHERIC:
          defines.add("HEMILIGHT$i");
          uniforms["vLightData$i"] = new EffectParameter(_hemisphericLightDataBinding(light, i));
          uniforms["vLightGround$i"] = new EffectParameter(_lightGroundBinding(light, i));
          break;
        default:
          break;
      }
      uniforms["vLightDiffuse$i"] = new EffectParameter(_lightDiffuseBinding(light, i));
      uniforms["vLightSpecular$i"] = new EffectParameter(_lightSpecularBinding(light, i));

      //uniforms["lightMatrix$i"] = new EffectParameter(_lightMatrixBinding(light));
    }

    _commonSrc = Effect.jointAsDefines(defines);

    return true;
  }

  EffectBinding _lightSpecularBinding(Node node, int i) {
    return (GraphicsDevice graphics, EffectContext context) {
      var light = node.light;
      graphics.setColor3(context.parameter.location, light.specular.scaled(light.intensity));
    };
  }

  EffectBinding _lightDiffuseBinding(Node node, int i) {
    return (GraphicsDevice graphics, EffectContext context) {
      var light = node.light;
      var diffuse = light.diffuse.scaled(light.intensity);
      graphics.setFloat4(context.parameter.location, diffuse.r, diffuse.g, diffuse.b, light.range);
    };
  }

  EffectBinding _lightGroundBinding(Node node, int i) {
    return (GraphicsDevice graphics, EffectContext context) {
      var light = node.light;
      var color = light.groundColor.scaled(light.intensity);
      graphics.setFloat3(context.parameter.location, color.r, color.g, color.b);
    };
  }

  EffectBinding _spotLightDirectionBinding(Node node, int i) {
    return (GraphicsDevice graphics, EffectContext context) {
      var light = node.light;
      var direction = light.direction.normalize();
      graphics.setFloat4(
          context.parameter.location,
          direction.x,
          direction.y,
          direction.z,
          Math.cos(light.angle * 0.5));
    };
  }

  EffectBinding _directionalLightDataBinding(Node node, int i) {
    var light = node.light;
    return (GraphicsDevice graphics, EffectContext context) {
      var direction = light.direction.normalize();
      graphics.setFloat4(context.parameter.location, direction.x, direction.y, direction.z, 1.0);
    };
  }

  EffectBinding _pointLightDataBinding(Node node, int i) {
    var light = node.light;
    return (GraphicsDevice graphics, EffectContext context) {
      var position = node.transform.worldPosition;
      graphics.setFloat4(context.parameter.location, position.x, position.y, position.z, 0.0);
    };
  }

  EffectBinding _spotLightDataBinding(Node node, int i) {
    var light = node.light;
    return (GraphicsDevice graphics, EffectContext context) {
      var position = node.transform.worldPosition;
      graphics.setFloat4(context.parameter.location, position.x, position.y, position.z, light.exponent);
    };
  }

  EffectBinding _hemisphericLightDataBinding(Node node, int i) {
    var light = node.light;
    return (GraphicsDevice graphics, EffectContext context) {
      var direction = light.direction.normalize();
      graphics.setFloat4(context.parameter.location, direction.x, direction.y, direction.z, 0.0);
    };
  }

  EffectBinding _lightMatrixBinding(Node light) => (GraphicsDevice graphics, EffectContext context) {
    var lightPos = light.transform.worldPosition;
    var lightDir = light.light.direction;
    var view = new Matrix4.identity().lookAt(lightPos, lightPos + lightDir, Vector3.up);
    var camera = context.camera as PerspectiveCamera;
    var projection = new Matrix4.perspective(radians(90.0), 1.0, camera.near, camera.far);
    var transform = projection * view;
    graphics.setMatrix4(context.parameter.location, transform);
  };
}
