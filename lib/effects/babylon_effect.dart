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

part of orange.effects.babylon;


/// shader code is from https://github.com/BabylonJS/Babylon.js
/// thanks to David Catuhe
class BabylonEffect extends Effect {

  static int EXPLICIT_MODE = 0;
  static int SPHERICAL_MODE = 1;
  static int PLANAR_MODE = 2;
  static int CUBIC_MODE = 3;
  static int PROJECTION_MODE = 4;
  static int SKYBOX_MODE = 5;

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
  Texture reflectionTexture;

  int coordinatesMode = SPHERICAL_MODE;
  bool opacityFromRGB = false;

  BabylonEffect() : super.load("packages/orange/effects/babylon");

  @override
  bool prepare(RenderData renderData) {
    if (!super.prepare(renderData)) return false;

    var defines = [];

    // diffuse
    if (renderData.material.mainTexture != null) {
      defines.add("DIFFUSE");
      defines.add("UV1");
      attributes["uv"] = new EffectParameter(EffectBindings.TEXCOORD_0);
      uniforms["diffuseMatrix"] = new EffectParameter(EffectBindings.MATRIX4_IDENTITY);
      uniforms["diffuseSampler"] = new EffectParameter(EffectBindings.DIFFUSE_TEXTURE);
      uniforms["vDiffuseInfos"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setFloat2(context.parameter.location, 0.0, 1.0);
      });
    }
    // ambient
    if (ambientTexture != null) {
      if (!ambientTexture.ready) return false;
      defines.add("AMBIENT");
      uniforms["ambientMatrix"] = new EffectParameter(EffectBindings.MATRIX4_IDENTITY);
      uniforms["ambientSampler"] = new EffectParameter(_textureBinding(ambientTexture));
      uniforms["vAmbientInfos"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setFloat2(context.parameter.location, 0.0, 1.0);
      });
    }
    // opacity
    if (opacityTexture != null) {
      if (!opacityTexture.ready) return false;
      defines.add("OPACITY");
      if (opacityFromRGB) defines.add("OPACITYRGB");
      uniforms["opacityMatrix"] = new EffectParameter(EffectBindings.MATRIX4_IDENTITY);
      uniforms["opacitySampler"] = new EffectParameter(_textureBinding(opacityTexture));
      uniforms["vOpacityInfos"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setFloat2(context.parameter.location, 0.0, 1.0);
      });
    }
    // reflection
    if (reflectionTexture != null) {
      if (!reflectionTexture.ready) return false;
      defines.add("REFLECTION");
      uniforms["reflectionMatrix"] = new EffectParameter(EffectBindings.MATRIX4_IDENTITY);
      var isCube = reflectionTexture.target == gl.TEXTURE_CUBE_MAP;
      if (isCube) {
        uniforms["reflectionCubeSampler"] = new EffectParameter(_textureBinding(reflectionTexture));
      } else {
        uniforms["reflection2DSampler"] = new EffectParameter(_textureBinding(reflectionTexture));
      }
      uniforms["vReflectionInfos"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setFloat3(context.parameter.location, coordinatesMode, 1.0, isCube ? 1.0 : 0.0);
      });
    }
    // emissive
    if (emissiveTexture != null) {
      if (!emissiveTexture.ready) return false;
      defines.add("EMISSIVE");
      uniforms["emissiveMatrix"] = new EffectParameter(EffectBindings.MATRIX4_IDENTITY);
      uniforms["emissiveSampler"] = new EffectParameter(_textureBinding(emissiveTexture));
      uniforms["vEmissiveInfos"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setFloat2(context.parameter.location, 0.0, 1.0);
      });
    }
    // specular
    if (specularTexture != null) {
      if (!specularTexture.ready) return false;
      defines.add("SPECULAR");
      uniforms["specularMatrix"] = new EffectParameter(EffectBindings.MATRIX4_IDENTITY);
      uniforms["specularSampler"] = new EffectParameter(_textureBinding(specularTexture));
      uniforms["vSpecularInfos"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setFloat2(context.parameter.location, 0.0, 1.0);
      });
    }
    // bump
    if (Orange.instance.graphicsDevice.caps.standardDerivatives && bumpTexture != null) {
      if (!bumpTexture.ready) return false;
      defines.add("BUMP");
      uniforms["bumpMatrix"] = new EffectParameter(EffectBindings.MATRIX4_IDENTITY);
      uniforms["bumpSampler"] = new EffectParameter(_textureBinding(bumpTexture));
      uniforms["vBumpInfos"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setFloat2(context.parameter.location, 0.0, 1.0);
      });
    }
    // fog
    if (renderData.renderSettings.fog) {
      defines.add("FOG");
    }
    // TODO UV2 & Skeleton

    attributes["position"] = new EffectParameter(EffectBindings.POSITION);
    attributes["normal"] = new EffectParameter(EffectBindings.NORMAL);

    uniforms["view"] = new EffectParameter(EffectBindings.VIEW);
    uniforms["viewProjection"] = new EffectParameter(EffectBindings.VIEW_PROJECTION);
    uniforms["world"] = new EffectParameter(EffectBindings.MODEL);

    // colors
    if (ambientColor != null) {
      uniforms["vAmbientColor"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setVector3(context.parameter.location, context.renderSettings.ambientLight * ambientColor);
      });
    }
    if (diffuseColor != null) {
      uniforms["vDiffuseColor"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setVector4(context.parameter.location, diffuseColor);
      });
    }
    if (specularColor != null) {
      uniforms["vSpecularColor"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setVector4(context.parameter.location, specularColor);
      });
    }
    if (emissiveColor != null) {
      uniforms["vEmissiveColor"] = new EffectParameter((GraphicsDevice graphics, RenderData context) {
        graphics.setVector3(context.parameter.location, emissiveColor);
      });
    }

    uniforms["vEyePosition"] = new EffectParameter(EffectBindings.EYE_POSITION);



    var lights = renderData.getLights();
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

    commonSrc = Effect.jointAsDefines(defines);

    return true;
  }

  EffectBinding _lightSpecularBinding(Node node, int i) {
    return (GraphicsDevice graphics, RenderData context) {
      var light = node.light;
      graphics.setVector3(context.parameter.location, light.specular.scaled(light.intensity));
    };
  }

  EffectBinding _lightDiffuseBinding(Node node, int i) {
    return (GraphicsDevice graphics, RenderData context) {
      var light = node.light;
      var diffuse = light.diffuse.scaled(light.intensity);
      graphics.setFloat4(context.parameter.location, diffuse.r, diffuse.g, diffuse.b, light.range);
    };
  }

  EffectBinding _lightGroundBinding(Node node, int i) {
    return (GraphicsDevice graphics, RenderData context) {
      var light = node.light;
      var color = light.groundColor.scaled(light.intensity);
      graphics.setFloat3(context.parameter.location, color.r, color.g, color.b);
    };
  }

  EffectBinding _spotLightDirectionBinding(Node node, int i) {
    return (GraphicsDevice graphics, RenderData context) {
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
    return (GraphicsDevice graphics, RenderData context) {
      var direction = light.direction.normalize();
      graphics.setFloat4(context.parameter.location, direction.x, direction.y, direction.z, 1.0);
    };
  }

  EffectBinding _pointLightDataBinding(Node node, int i) {
    var light = node.light;
    return (GraphicsDevice graphics, RenderData context) {
      var position = node.transform.worldPosition;
      graphics.setFloat4(context.parameter.location, position.x, position.y, position.z, 0.0);
    };
  }

  EffectBinding _spotLightDataBinding(Node node, int i) {
    var light = node.light;
    return (GraphicsDevice graphics, RenderData context) {
      var position = node.transform.worldPosition;
      graphics.setFloat4(context.parameter.location, position.x, position.y, position.z, light.exponent);
    };
  }

  EffectBinding _hemisphericLightDataBinding(Node node, int i) {
    var light = node.light;
    return (GraphicsDevice graphics, RenderData context) {
      var direction = light.direction.normalize();
      graphics.setFloat4(context.parameter.location, direction.x, direction.y, direction.z, 0.0);
    };
  }

  EffectBinding _lightMatrixBinding(Node light) => (GraphicsDevice graphics, RenderData context) {
    var lightPos = light.transform.worldPosition;
    var lightDir = light.light.direction;
    var view = new Matrix4.identity().lookAt(lightPos, lightPos + lightDir, Vector3.up);
    var camera = context.camera as PerspectiveCamera;
    var projection = new Matrix4.perspective(radians(90.0), 1.0, camera.near, camera.far);
    var transform = projection * view;
    graphics.setMatrix4(context.parameter.location, transform);
  };

  EffectBinding _textureBinding(Texture texture) {
    return (GraphicsDevice graphics, RenderData context) {
      var channel = samplers.indexOf(context.parameter.name);
      if (channel >= 0) graphics.bindTexture(texture, channel);
    };
  }

  @override
  void dispose() {
    super.dispose();
    if (ambientTexture != null) ambientTexture.dispose();
    if (opacityTexture != null) opacityTexture.dispose();
    if (reflectionTexture != null) reflectionTexture.dispose();
    if (emissiveTexture != null) emissiveTexture.dispose();
    if (specularTexture != null) specularTexture.dispose();
    if (bumpTexture != null) bumpTexture.dispose();
  }
}













