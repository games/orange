part of orange_examples;





class TestBabylonScene extends Scene {
  TestBabylonScene(Camera camera) : super(camera);

  @override
  void enter() {

    var loader = new BabylonLoader();
    loader.load(graphicsDevice.ctx, "/orange/models/babylon/schooner.babylon", new BabylonScene()).then((s) {
      if (s.camera == null) {
        s.camera = camera;
      }
      engine.enter(s);
    });
  }

}

class BabylonScene extends Scene {

  Mesh ship;
  
  @override
  void enter() {

    var diffuseTexture = Texture.load(graphicsDevice.ctx, {
      "path": "/orange/models/babylon/PLAYER_SHIP_SCHOONER_ID1.jpg",
      "sampler": new Sampler()
                ..minFilter = gl.NEAREST_MIPMAP_NEAREST
                ..magFilter = gl.NEAREST,
      "flip": true
    });

    ship = new Mesh();
    var boundingInfo = BoundingInfo.compute(nodes);
    var combina;
    combina = (child) {
      if (child is Mesh) {
        if (child.material != null) {
          child.material.diffuseTexture = diffuseTexture;
          child.material.backFaceCulling = false;
        }
      }
      child.children.forEach(combina);
      ship.add(child);
    };
    nodes.forEach(combina);
    nodes.clear();
    add(ship);
    
    var box = boundingInfo.boundingBox;
    var radius = boundingInfo.boundingSphere.radius;
    camera.position = box.center + new Vector3(radius / 2, -radius / 4, radius / 2);
    camera.lookAt(box.center - new Vector3(0.0, radius / 3, 0.0));


    var light1 = new DirectionalLight(0xffffff);
    light1.intensity = 0.2;
    light1.specular = new Color.fromHex(0xffffff);
    light1.translate(100.0, 300.0, 300.0);
    light1.direction = new Vector3(-1.0, -1.0, 0.0).normalize();
    add(light1);
    
    var water = new PlaneMesh(width: 10000, height: 10000, ground: true);
    water.translate(0.0, 0.0);
    water.material = new WaterMaterial(graphicsDevice);
    water.material.bumpTexture = Texture.load(graphicsDevice.ctx, {
      "path": "textures/waternormals.jpg"
    });
    (water.material as WaterMaterial).waterDirection = new Vector2(0.0, -1.0);
    water.material.bumpTexture.uScale = 2.0;
    water.material.bumpTexture.vScale = 2.0;
    add(water);

    var skybox = new Cube(width: 1000, height: 1000, depth: 1000);
    skybox.material = new StandardMaterial();
    skybox.material.backFaceCulling = false;
    skybox.material.reflectionTexture = new CubeTexture("textures/cube/skybox/sky");
    skybox.material.reflectionTexture.coordinatesMode = Texture.SKYBOX_MODE;
    skybox.material.diffuseColor = new Color.fromList([0.0, 0.0, 0.0]);
    skybox.material.specularColor = new Color.fromList([0.0, 0.0, 0.0]);
    add(skybox);
  }
  
  @override
  void enterFrame(num elapsed, num interval) {
    ship.setTranslation(0.0, sin(elapsed / 1000.0) * .5, 0.0);
  }

  @override
  exit() {
    removeChildren();
  }

}
