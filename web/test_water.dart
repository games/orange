part of orange_examples;





class TestWaterScene extends Scene {

  TestWaterScene(Camera camera) : super(camera);

  @override
  void enter() {
    camera.setTranslation(-40.0, 40.0, 0.0);
    camera.lookAt(new Vector3.zero());

    //TODO skybox

    var ground = new PlaneMesh(width: 10000, height: 10000, ground: true);
    ground.translate(0.0, -10.0);
    ground.material = new StandardMaterial();
    ground.material.diffuseTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/terrain/grasslight-big.jpg",
      "sampler": new Sampler()
          ..minFilter = gl.NEAREST_MIPMAP_NEAREST
          ..magFilter = gl.NEAREST_MIPMAP_NEAREST
    });
    ground.material.diffuseTexture.uScale = 60.0;
    ground.material.diffuseTexture.vScale = 60.0;
    add(ground);

    // TODO height map

    // TODO water


    var light = new DirectionalLight(0xFFFFFF);
    light.direction.setValues(-1.0, -1.0, -1.0);
    add(light);
  }

  @override
  exit() {
    super.exit();
    removeChildren();
  }
}
