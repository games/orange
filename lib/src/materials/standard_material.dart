part of orange;





class StandardMaterial extends Material {
  //  Scene _scene;
  String _cachedDefines;

  StandardMaterial() {
    technique = new Technique();
    technique.pass = new Pass();
  }

  bool ready(Mesh mesh) {
    var scene = mesh.scene;
    var defines = [];
    if (scene.texturesEnabled) {
      if (diffuseTexture != null) {
        defines.add("#define DIFFUSE");
      }
      // TODO ambient, opacity, reflection, emissive, specular
    }
    var renderer = scene.graphicsDevice;
    if (renderer.caps.standardDerivatives && bumpTexture != null) {
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
          var shadowGenerator = light.shadowRenderer;
          defines.add("#define SHADOW${i}");
          if (!shadowsActivated) {
            defines.add("#define SHADOWS");
            shadowsActivated = true;
          }
          if (shadowGenerator.useVarianceShadowMap) {
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
  void bind(Mesh mesh) {
    var scene = mesh.scene;
    var device = scene.graphicsDevice;
    var ctx = device.ctx;
    var pass = technique.pass;
    var shader = pass.shader;
    var camera = scene.camera;

    device.use(pass);
    device.bindUniform(shader, Semantics.modelMat, mesh.worldMatrix.storage);
    device.bindUniform(shader, Semantics.viewMat, camera.viewMatrix.storage);
    device.bindUniform(shader, Semantics.viewProjectionMat, camera.viewProjectionMatrix.storage);
    device.bindUniform(shader, Semantics.projectionMat, camera.projectionMatrix.storage);
//    device.bindUniform(shader, Semantics.normalMat, (camera.viewMatrix * mesh.worldMatrix).normalMatrix3().storage);

    //textures
    // TODO ambient, opacity, reflection, emissive, specular, bump
    if (diffuseTexture != null) {
      device.bindTexture(shader, Semantics.texture, diffuseTexture);
      // TODO x: uv or uv2; y: alpha of texture
      device.bindUniform(shader, "vDiffuseInfos", new Float32List.fromList([0.0, 1.0]));
      // TODO offset, scale, ang
      device.bindUniform(shader, "diffuseMatrix", new Matrix4.identity().storage);
    }
    if (bumpTexture != null && device.caps.standardDerivatives) {
      device.bindTexture(shader, "bumpSampler", bumpTexture);
      // TODO x: uv or uv2; y: alpha of texture
      device.bindUniform(shader, "vBumpInfos", new Float32List.fromList([0.0, 1.0]));
      // TODO offset, scale, ang
      device.bindUniform(shader, "bumpMatrix", new Matrix4.identity().storage);
    }

    // colors
    device.bindUniform(shader, Semantics.cameraPosition, camera.position.storage);
    if (shininess != null) {
      device.bindUniform(shader, Semantics.shininess, shininess);
    }
    if (specularColor != null) {
      device.bindUniform(shader, Semantics.specularColor, specularColor.storage);
    }
    if (ambientColor != null) {
      // TODO should multipy to global ambient color
      device.bindUniform(shader, Semantics.ambientColor, ambientColor.rgb.storage);
    }
    if (diffuseColor != null) {
      device.bindUniform(shader, Semantics.diffuseColor, diffuseColor.storage);
    }
    if (emissiveColor != null) {
      device.bindUniform(shader, Semantics.emissiveColor, emissiveColor.rgb.storage);
    }

    //lights
    if (scene.lightsEnabled) {
      var lights = scene._lights;
      for (var i = 0; i < lights.length && i < Light.MAX_LIGHTS; i++) {
        var light = lights[i];
        light.updateMatrix();
        light.bind(ctx, shader, i);
        var diffuse = light.diffuse.scaled(light.intensity);
        // [color + range]
        device.bindUniform(shader, "vLightDiffuse${i}", new Float32List.fromList([diffuse.red, diffuse.green, diffuse.blue, light.range]));
        device.bindUniform(shader, "vLightSpecular${i}", light.specular.scaled(light.intensity).rgb.storage);
        if (mesh.receiveShadows && light is DirectionalLight) {
          var shadowGenerator = light.shadowRenderer;
          device.bindUniform(shader, "lightMatrix${i}", shadowGenerator.transformMatrix.storage);
          device.bindTexture(shader, "shadowSampler${i}", shadowGenerator.shadowMap);
          device.bindUniform(shader, "darkness${i}", shadowGenerator.darkness);
        }
      }
    }

    var skeleton = mesh.skeleton;
    if (skeleton != null) {
      skeleton.updateMatrix();
      device.bindUniform(shader, Semantics.jointMat, skeleton.jointMatrices);
    }

    if(scene.fogMode != Scene.FOGMODE_NONE) {
      device.bindUniform(shader, "vFogInfos", new Float32List.fromList([scene.fogMode.toDouble(), scene.fogStart, scene.fogEnd, scene.fogDensity]));
      device.bindUniform(shader, "vFogColor", scene.fogColor.rgb.storage);
    }
  }




}
