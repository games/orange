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

  PhysicallyBasedMaterial() {
    technique = new Technique();
    technique.pass = new Pass();
  }

  @override
  bool ready([Mesh mesh]) {
    if (mesh == null) return false;

    if (diffuseTexture != null && !diffuseTexture.ready) return false;

    if (bumpTexture != null && !bumpTexture.ready) return false;

    if (technique.pass.shader == null) {
      technique.pass.shader = new Shader(Orange.instance.graphicsDevice.ctx, SHADER_PHYSICALLY_BASED_VS, SHADER_PHYSICALLY_BASED_FS, common: "");
    }
    return technique.pass.shader.ready;
  }

  @override
  void bind({Mesh mesh, Matrix4 worldMatrix}) {
    var device = Orange.instance.graphicsDevice;
    var scene = mesh.scene;
    
    device.bindMatrix4(Semantics.modelMat, mesh.worldMatrix);

    if (diffuseTexture != null) {
      device.bindTexture(Semantics.texture, diffuseTexture);
//      device.bindFloat2("vDiffuseInfos", diffuseTexture.coordinatesIndex, diffuseTexture.level);
//      device.bindMatrix4("diffuseMatrix", diffuseTexture.textureMatrix);
    }
    if (bumpTexture != null) {
      device.bindTexture("bumpSampler", bumpTexture);
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

    device.bindFloat("uAlbedo", albedo);
    device.bindFloat("uRoughess", roughness);
    device.bindFloat("uReflectivity", reflectivity);

  }

  @override
  void unbind() {

  }

}










