part of orange;





class StandardMaterial extends Material {
  Scene _scene;
  String _cachedDefines;

  StandardMaterial(this._scene) {
    technique = new Technique();
    technique.pass = new Pass();
  }

  bool ready(Mesh mesh) {
    var defines = [];
    if (_scene.texturesEnabled) {
      if (diffuseTexture != null) {
        defines.add("#define DIFFUSE");
      }
      // TODO ambient, opacity, reflection, emissive, specular, bump
    }
    var renderer = _scene.renderer;
    if (renderer.caps.standardDerivatives && bumpTexture != null) {
      defines.add("#define BUMP");
    }
    // FOG
    if (_scene.fogMode != Scene.FOGMODE_NONE) {
      defines.add("#define FOG");
    }
    var shadowsActivated = false;
    if (_scene.lightsEnabled) {
      for (var i = 0; i < _scene.lights.length && i < MAX_LIGHTS; i++) {
        defines.add("#define LIGHT$i");
        var light = _scene.lights[i];
        if (light.type == Light.SPOTLIGHT) {
          defines.add("#define SPOTLIGHT$i");
        } else {
          defines.add("#define POINTDIRLIGHT$i");
        }
        // shadows
        // TODO
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
      technique.pass.shader = new Shader(renderer.ctx, SHADER_STANDARD_VS, SHADER_STANDARD_FS, common: finalDefines);
      return technique.pass.shader.ready;
    }
    return true;
  }

  @override
  void bind(Renderer2 renderer, Scene scene, Mesh mesh) {
    var pass = technique.pass;
    var shader = pass.shader;
    var ctx = renderer.ctx;
    var camera = scene.camera;

    renderer.use(pass);
    renderer.bindUniform(shader, Semantics.modelMat, mesh.worldMatrix.storage);
    renderer.bindUniform(shader, Semantics.viewMat, camera.viewMatrix.storage);
    renderer.bindUniform(shader, Semantics.viewProjectionMat, camera.viewProjectionMatrix.storage);
    renderer.bindUniform(shader, Semantics.projectionMat, camera.projectionMatrix.storage);
    renderer.bindUniform(shader, Semantics.normalMat, (camera.viewMatrix * mesh.worldMatrix).normalMatrix3().storage);

    //textures
    // TODO ambient, opacity, reflection, emissive, specular, bump
    if (diffuseTexture != null) {
      renderer.bindTexture(shader, diffuseTexture);
      // x: uv or uv2; y: alpha of texture
      renderer.bindUniform(shader, "vDiffuseInfos", new Float32List.fromList([0.0, 1.0]));
      renderer.bindUniform(shader, "diffuseMatrix", new Matrix4.identity().storage);
    }

    // colors
    renderer.bindUniform(shader, Semantics.cameraPosition, camera.position.storage);
    if (shininess != null) {
      renderer.bindUniform(shader, Semantics.shininess, shininess);
    }
    if (specularColor != null) {
      renderer.bindUniform(shader, Semantics.specularColor, specularColor.storage);
    }
    if (ambientColor != null) {
      // TODO should multipy to global ambient color
      renderer.bindUniform(shader, Semantics.ambientColor, ambientColor.rgb.storage);
    }
    if (diffuseColor != null) {
      renderer.bindUniform(shader, Semantics.diffuseColor, diffuseColor.storage);
    }
    if (emissiveColor != null) {
      renderer.bindUniform(shader, Semantics.emissiveColor, emissiveColor.rgb.storage);
    }

    //lights
    if (scene.lightsEnabled) {
      var lights = scene.lights;
      for (var i = 0; i < lights.length && i < MAX_LIGHTS; i++) {
        var light = lights[i];
        light.updateMatrix();
        light.bind(ctx, shader, i);
        var diffuse = light.diffuse.scaled(light.intensity);
        // [color + range]
        renderer.bindUniform(shader, "vLightDiffuse${i}", new Float32List.fromList([diffuse.red, diffuse.green, diffuse.blue, light.range]));
        renderer.bindUniform(shader, "vLightSpecular${i}", light.specular.scaled(light.intensity).rgb.storage);
        //TODO shadows
        if (mesh.receiveShadows) {
          // light matrix
          // shadowSampler
          // darkness
        }
      }
    }

    if (mesh.skeleton != null) {
      mesh.skeleton.updateMatrix();
      renderer.bindUniform(shader, Semantics.jointMat, mesh.skeleton.jointMatrices);
    }

    //TODO fog
  }




}
