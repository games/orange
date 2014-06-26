part of orange;




class ShaderMaterial extends Material {
  GraphicsDevice _graphicsDevice;
  dynamic afterBinding;

  ShaderMaterial(this._graphicsDevice, String vertexSource, String fragmentSource, {this.afterBinding}) {
    technique = new Technique();
    technique.pass = new Pass();
    technique.pass.shader = new Shader(_graphicsDevice.ctx, vertexSource, fragmentSource);
  }

  ShaderMaterial.load(this._graphicsDevice, String url, {this.afterBinding}) {
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
    if (mesh != null) worldMatrix = mesh.worldMatrix;

    device.bindMatrix4(Semantics.modelMat, worldMatrix);
    if (shader.uniforms.containsKey(Semantics.worldViewProjection)) {
      device.bindMatrix4(Semantics.worldViewProjection, (camera.projectionMatrix * camera.viewMatrix * worldMatrix));
    }
    if (afterBinding != null) {
      afterBinding(this, mesh, worldMatrix);
    }
    // TODO
    // other things
  }

}
