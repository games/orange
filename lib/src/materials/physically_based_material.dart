part of orange;





class PhysicallyBasedMaterial extends Material {

  // Albedo is the base color input, commonly known as a diffuse map.
  // 0.0 ~ 1.0
  double albedo = 1.0;
  // defines how rough or smooth the surface of a material is.
  // 0.0 ~ 1.0
  double roughness = 0.7;
  // F0
  double reflectivity = 0.3;

  String _cachedDefines;

  PhysicallyBasedMaterial() {
    technique = new Technique();
    technique.pass = new Pass();
  }

  @override
  bool ready([Mesh mesh]) {
    if (mesh == null) return false;

    var defines = [];
    var scene = mesh.scene;
    var device = scene.graphicsDevice;

    if (diffuseTexture != null) {
      if (!diffuseTexture.ready) return false;
      defines.add("#define DIFFUSE");
    }

    if (device.caps.standardDerivatives && bumpTexture != null) {
      if (!bumpTexture.ready) return false;
      defines.add("#define BUMP");
    }

    if (scene.lightsEnabled) {
      for (var i = 0; i < scene._lights.length && i < Light.MAX_LIGHTS; i++) {
        defines.add("#define LIGHT$i");
        var light = scene._lights[i];
        if (light is SpotLight) {
          defines.add("#define SPOTLIGHT$i");
        } else if (light is HemisphericLight) {
          defines.add("#define HEMILIGHT$i");
        } else {
          defines.add("#define POINTDIRLIGHT$i");
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
      if (technique.pass.shader != null) technique.pass.shader.dispose();
      technique.pass.shader = new Shader(device.ctx, SHADER_PHYSICALLY_BASED_VS, SHADER_PHYSICALLY_BASED_FS, common: finalDefines);
    }
    return technique.pass.shader.ready;
  }

  @override
  void bind({Mesh mesh, Matrix4 worldMatrix}) {
    var device = Orange.instance.graphicsDevice;
    var scene = mesh.scene;
    var shader = technique.pass.shader;

    device.bindMatrix4(Semantics.modelMat, mesh.worldMatrix);

    if (diffuseTexture != null) {
      device.bindTexture(Semantics.texture, diffuseTexture);
      device.bindFloat2("vDiffuseInfos", diffuseTexture.coordinatesIndex, diffuseTexture.level);
      device.bindMatrix4("diffuseMatrix", diffuseTexture.textureMatrix);
    }
    if (bumpTexture != null) {
      device.bindTexture("bumpSampler", bumpTexture);
      device.bindFloat2("vBumpInfos", bumpTexture.coordinatesIndex, bumpTexture.level);
      device.bindMatrix4("bumpMatrix", bumpTexture.textureMatrix);
    }

    if (shininess != null) {
      device.bindFloat(Semantics.shininess, shininess);
    }
    if (specularColor != null) {
      device.bindFloat4(Semantics.specularColor, specularColor.red, specularColor.green, specularColor.blue, specularPower);
    }
    if (ambientColor != null) {
      device.bindColor3(Semantics.ambientColor, scene.ambientColor * ambientColor);
    }
    if (diffuseColor != null) {
      device.bindFloat4(Semantics.diffuseColor, diffuseColor.red, diffuseColor.green, diffuseColor.blue, alpha * mesh.visibility);
    }
    if (emissiveColor != null) {
      device.bindColor3(Semantics.emissiveColor, emissiveColor);
    }

    if (scene.lightsEnabled) {
      var lights = scene._lights;
      for (var i = 0; i < lights.length && i < Light.MAX_LIGHTS; i++) {
        var light = lights[i];
        light.bind(device.ctx, shader, i);
        var diffuse = light.diffuse.scaled(light.intensity);
        // [color + range]
        device.bindFloat4("vLightDiffuse${i}", diffuse.red, diffuse.green, diffuse.blue, light.range);
        device.bindColor3("vLightSpecular${i}", light.specular.scaled(light.intensity));
      }
    }

    var skeleton = mesh.skeleton;
    if (skeleton != null) {
      skeleton.updateMatrix();
      device.bindMatrix4List(Semantics.jointMat, skeleton.jointMatrices);
    }

    device.bindFloat("uAlbedo", albedo);
    device.bindFloat("uRoughess", roughness);
    device.bindFloat("uReflectivity", reflectivity);

  }

  @override
  void unbind() {

  }

}





