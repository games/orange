part of orange;





class StandardMaterial extends Material {
  //  Scene _scene;
  String _cachedDefines;

  StandardMaterial() {
    technique = new Technique();
    technique.pass = new Pass();
  }

  bool ready([Mesh mesh]) {
    if (mesh == null) return false;
    var scene = mesh.scene;
    var defines = [];
    if (scene.texturesEnabled) {
      if (diffuseTexture != null) {
        if(!diffuseTexture.ready) return false;
        defines.add("#define DIFFUSE");
      }
      if (ambientTexture != null) {
        if (!ambientTexture.ready) return false;
        defines.add("#define AMBIENT");
      }
      if (opacityTexture != null && opacityTexture.ready) {
        if (!opacityTexture.ready) return false;
        defines.add("#define OPACITY");
        if (opacityTexture.getAlphaFromRGB) {
          defines.add("#define OPACITYRGB");
        }
      }
      if (reflectionTexture != null) {
        if (!reflectionTexture.ready) return false;
        defines.add("#define REFLECTION");
      }
      if (emissiveTexture != null) {
        if (!emissiveTexture.ready) return false;
        defines.add("#define EMISSIVE");
      }
      if (specularTexture != null) {
        if (!specularTexture.ready) return false;
        defines.add("#define SPECULAR");
      }
    }
    var renderer = scene.graphicsDevice;
    if (renderer.caps.standardDerivatives && bumpTexture != null) {
      if (!bumpTexture.ready) return false;
      defines.add("#define BUMP");
    }
    // FOG
    if (scene.fogMode != Scene.FOGMODE_NONE) {
      defines.add("#define FOG");
    }
    var shadowsActivated = false;
    if (scene.lightsEnabled) {
      for (var i = 0; i < scene._lights.length && i < Light.MAX_LIGHTS; i++) {
        defines.add("#define LIGHT$i");
        var light = scene._lights[i];
        if (light.type == Light.SPOTLIGHT) {
          defines.add("#define SPOTLIGHT$i");
        } else {
          defines.add("#define POINTDIRLIGHT$i");
        }
        // shadows
        if (mesh.receiveShadows && light is DirectionalLight) {
          var shadowRenderer = light.shadowRenderer;
          defines.add("#define SHADOW${i}");
          if (!shadowsActivated) {
            defines.add("#define SHADOWS");
            shadowsActivated = true;
          }
          if (shadowRenderer.useVarianceShadowMap) {
            defines.add("#define SHADOWVSM${i}");
          }
        }
      }
    }
    if (mesh.geometry != null) {
      var geometry = mesh.geometry;
      if (geometry.buffers.containsKey(Semantics.texcoords)) {
        defines.add("#define UV1");
      }
      if (geometry.buffers.containsKey(Semantics.texcoords2)) {
        defines.add("#define UV2");
      }
      if (mesh.skeleton != null) {
        defines.add("#define BONES");
        defines.add("#define BonesPerMesh ${mesh.skeleton.joints.length}");
        defines.add("#define BONES4");
      }
    }
    var finalDefines = defines.join("\n");
    if (_cachedDefines != finalDefines) {
      _cachedDefines = finalDefines;
      // TODO cache ??
      if (technique.pass.shader != null) technique.pass.shader.dispose();
      technique.pass.shader = new Shader(renderer.ctx, SHADER_STANDARD_VS, SHADER_STANDARD_FS, common: finalDefines);
      return technique.pass.shader.ready;
    }
    return true;
  }

  @override
  void bind({Mesh mesh, Matrix4 worldMatrix}) {
    var scene = mesh.scene;
    var device = scene.graphicsDevice;
    var ctx = device.ctx;
    var shader = technique.pass.shader;
    var camera = scene.camera;

    device.bindUniform(Semantics.modelMat, mesh.worldMatrix.storage);

    //    device.bindUniform(Semantics.viewMat, camera.viewMatrix.storage);
    //    device.bindUniform(Semantics.viewProjectionMat, camera.viewProjectionMatrix.storage);
    //    device.bindUniform(Semantics.projectionMat, camera.projectionMatrix.storage);

    //    device.bindUniform(Semantics.normalMat, (camera.viewMatrix * mesh.worldMatrix).normalMatrix3().storage);

    //textures
    // TODO ambient, opacity, reflection, emissive, specular, bump
    var textureMatrix = new Matrix4.identity();
    if (diffuseTexture != null && diffuseTexture.ready) {
      device.bindTexture(Semantics.texture, diffuseTexture);
      // TODO x: uv or uv2; y: alpha of texture
      device.bindUniform("vDiffuseInfos", new Float32List.fromList([diffuseTexture.coordinatesIndex, diffuseTexture.level]));
      // TODO offset, scale, ang
      device.bindUniform("diffuseMatrix", textureMatrix.storage);
    }
    if (ambientTexture != null && ambientTexture.ready) {
      device.bindTexture("ambientSampler", ambientTexture);
      device.bindUniform("vAmbientInfos", new Float32List.fromList([ambientTexture.coordinatesIndex, ambientTexture.level]));
      device.bindUniform("ambientMatrix", textureMatrix.storage);
    }
    if (opacityTexture != null && opacityTexture.ready) {
      device.bindTexture("opacitySampler", opacityTexture);
      device.bindUniform("vOpacityInfos", new Float32List.fromList([opacityTexture.coordinatesIndex, opacityTexture.level]));
      device.bindUniform("opacityMatrix", textureMatrix.storage);
    }
    if (reflectionTexture != null && reflectionTexture.ready) {
      if (reflectionTexture.isCube) {
        device.bindTexture("reflectionCubeSampler", reflectionTexture);
      } else {
        device.bindTexture("reflection2DSampler", reflectionTexture);
      }
      device.bindUniform("vReflectionInfos", new Float32List.fromList([reflectionTexture.coordinatesMode.toDouble(), reflectionTexture.level, reflectionTexture.isCube ? 1.0 : 0.0]));
      device.bindUniform("reflectionMatrix", textureMatrix.storage);
    }
    if (emissiveTexture != null && emissiveTexture.ready) {
      device.bindTexture("emissiveSampler", emissiveTexture);
      device.bindUniform("vEmissiveInfos", new Float32List.fromList([0.0, 1.0]));
      device.bindUniform("emissiveMatrix", new Matrix4.identity().storage);
    }
    if (specularTexture != null && specularTexture.ready) {
      device.bindTexture("specularSampler", specularTexture);
      device.bindUniform("vSpecularInfos", new Float32List.fromList([0.0, 1.0]));
      device.bindUniform("specularMatrix", new Matrix4.identity().storage);
    }
    if (bumpTexture != null && bumpTexture.ready && device.caps.standardDerivatives) {
      device.bindTexture("bumpSampler", bumpTexture);
      // TODO x: uv or uv2; y: alpha of texture
      device.bindUniform("vBumpInfos", new Float32List.fromList([0.0, 1.0]));
      // TODO offset, scale, ang
      device.bindUniform("bumpMatrix", new Matrix4.identity().storage);
    }

    // colors
    if (shininess != null) {
      device.bindUniform(Semantics.shininess, shininess);
    }
    if (specularColor != null) {
      device.bindUniform(Semantics.specularColor, specularColor.storage);
    }
    if (ambientColor != null) {
      // TODO should multipy to global ambient color
      device.bindUniform(Semantics.ambientColor, ambientColor.rgb.storage);
    }
    if (diffuseColor != null) {
      device.bindUniform(Semantics.diffuseColor, diffuseColor.storage);
    }
    if (emissiveColor != null) {
      device.bindUniform(Semantics.emissiveColor, emissiveColor.rgb.storage);
    }

    //lights
    if (scene.lightsEnabled) {
      var lights = scene._lights;
      for (var i = 0; i < lights.length && i < Light.MAX_LIGHTS; i++) {
        var light = lights[i];
        //  ight.updateMatrix();
        light.bind(ctx, shader, i);
        var diffuse = light.diffuse.scaled(light.intensity);
        // [color + range]
        device.bindUniform("vLightDiffuse${i}", new Float32List.fromList([diffuse.red, diffuse.green, diffuse.blue, light.range]));
        device.bindUniform("vLightSpecular${i}", light.specular.scaled(light.intensity).rgb.storage);
        if (mesh.receiveShadows && light is DirectionalLight) {
          var shadowRenderer = light.shadowRenderer;
          device.bindUniform("lightMatrix${i}", shadowRenderer.transformMatrix.storage);
          device.bindTexture("shadowSampler${i}", shadowRenderer.shadowMap);
          device.bindUniform("darkness${i}", shadowRenderer.darkness);
        }
      }
    }

    var skeleton = mesh.skeleton;
    if (skeleton != null) {
      skeleton.updateMatrix();
      device.bindUniform(Semantics.jointMat, skeleton.jointMatrices);
    }

    if (scene.fogMode != Scene.FOGMODE_NONE) {
      device.bindUniform("vFogInfos", new Float32List.fromList([scene.fogMode.toDouble(), scene.fogStart, scene.fogEnd, scene.fogDensity]));
      device.bindUniform("vFogColor", scene.fogColor.rgb.storage);
    }
  }




}
