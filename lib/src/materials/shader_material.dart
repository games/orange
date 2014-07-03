part of orange;




class ShaderMaterial extends Material {
  GraphicsDevice _graphicsDevice;
  dynamic beforReady;
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
    var isReady = true;
    if(beforReady != null) isReady = beforReady(this);
    if(!isReady) return false;
    return technique.pass.shader.ready;
  }

  @override
  void bind({Mesh mesh, Matrix4 worldMatrix}) {
    var scene = Orange.instance.scene;
    var device = Orange.instance.graphicsDevice;
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
