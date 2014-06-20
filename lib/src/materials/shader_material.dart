part of orange;




class ShaderMaterial extends Material {
  GraphicsDevice _graphicsDevice;

  ShaderMaterial(this._graphicsDevice) {
    technique = new Technique();
    technique.pass = new Pass();
  }

  @override
  bool ready([Mesh mesh]) {
    if (technique.pass.shader == null) technique.pass.shader = new Shader(_graphicsDevice.ctx, SHADER_COLOR_VS, SHADER_COLOR_FS);
    return technique.pass.shader.ready;
  }

  @override
  void bind({Mesh mesh, Matrix4 worldMatrix}) {
    var scene = Director.instance.scene;
    var device = Director.instance.graphicsDevice;
    var shader = technique.pass.shader;
    var camera = scene.camera;
    if (mesh != null) {
      device.bindUniform(shader, Semantics.modelMat, mesh.worldMatrix.storage);
    } else {
      device.bindUniform(shader, Semantics.modelMat, worldMatrix.storage);
    }
    device.bindUniform(shader, Semantics.viewMat, camera.viewMatrix.storage);
    device.bindUniform(shader, Semantics.viewProjectionMat, camera.viewProjectionMatrix.storage);
    device.bindUniform(shader, Semantics.projectionMat, camera.projectionMatrix.storage);
    if (shader.uniforms.containsKey("worldViewProjection")) {
      device.bindUniform(shader, "worldViewProjection", (camera.projectionMatrix * camera.viewMatrix * worldMatrix).storage);
    }

    // TODO
    // other things
  }

}
