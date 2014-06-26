part of orange;




class ShaderMaterial extends Material {
  GraphicsDevice _graphicsDevice;

  ShaderMaterial(this._graphicsDevice, String vertexSource, String fragmentSource) {
    technique = new Technique();
    technique.pass = new Pass();
    technique.pass.shader = new Shader(_graphicsDevice.ctx, vertexSource, fragmentSource);
  }

  ShaderMaterial.load(this._graphicsDevice, String url) {
    technique = new Technique();
    technique.pass = new Pass();
    technique.pass.shader = new Shader.load(url);
  }

  @override
  bool ready([Mesh mesh]) {
    return technique.pass.shader.ready;
  }

  @override
  void bind({Mesh mesh, Matrix4 worldMatrix}) {
    var scene = Director.instance.scene;
    var device = Director.instance.graphicsDevice;
    var shader = technique.pass.shader;
    var camera = scene.camera;
    if (mesh != null) {
      device.bindMatrix4(Semantics.modelMat, mesh.worldMatrix);
    } else {
      device.bindMatrix4(Semantics.modelMat, worldMatrix);
    }
    device.bindMatrix4(Semantics.viewMat, camera.viewMatrix);
    device.bindMatrix4(Semantics.viewProjectionMat, camera.viewProjectionMatrix);
    device.bindMatrix4(Semantics.projectionMat, camera.projectionMatrix);
    if (shader.uniforms.containsKey("worldViewProjection")) {
      device.bindMatrix4("worldViewProjection", (camera.projectionMatrix * camera.viewMatrix * worldMatrix));
    }

    // TODO
    // other things
  }

}
