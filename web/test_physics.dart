part of orange_examples;



class PhysicsScene extends Scene {

  PhysicsScene(Camera camera) : super(camera);
  Timer timer;

  @override
  enter() {
    camera.setTranslation(0.0, 2.0, 10.0);
    camera.lookAt(new Vector3.zero());

    enablePhysics();

    var sphereMaterial = new StandardMaterial();

    var sphere = new SphereMesh(radius: 0.5);
    sphere.setTranslation(0.0, 0.0, -1.0);
    sphere.material = sphereMaterial;
    sphere.castShadows = true;
    sphere.showBoundingBox = true;
    sphere.setPhysicsState(PhysicsEngine.SphereImpostor, new PhysicsBodyCreationOptions(mass: 1.0));
    add(sphere);

    var sphere1 = new SphereMesh(radius: 0.8);
    sphere1.setTranslation(-0.2, 2.0, -1.0);
    sphere1.material = sphereMaterial;
    sphere1.castShadows = true;
    sphere1.showBoundingBox = true;
    sphere1.setPhysicsState(PhysicsEngine.SphereImpostor, new PhysicsBodyCreationOptions(mass: 2.0));
    add(sphere1);

    sphere.setPhysicsLinkWith(sphere1, new Vector3(0.0, 1.5, 0.0), new Vector3(0.0, -1.5, 0.0));

    var balls = [];
    var rnd = new Random();
    var generator = (count) {
      for (var i = 0; i < count; i++) {
        var sphere2 = new SphereMesh(radius: 0.5 * rnd.nextDouble() + 0.3);
        sphere2.setTranslation(rnd.nextDouble() * 8 - 4, 3.0, rnd.nextDouble() * 8 - 4);
        sphere2.material = sphereMaterial;
        sphere2.castShadows = true;
        sphere2.setPhysicsState(PhysicsEngine.SphereImpostor, new PhysicsBodyCreationOptions(mass: 1.0));
        add(sphere2);
        balls.add(sphere2);
      }
    };
    generator(10);

    var controllers = html.querySelector("#controllers");
    var label = new html.DivElement();
    label.innerHtml = "${balls.length + 2} Balls";

    var btn = new html.ButtonElement();
    btn.text = "New Balls";
    btn.onClick.listen((e) {
      generator(10);
      label.innerHtml = "${balls.length + 2} Balls";
    });
    controllers.children.add(btn);

    btn = new html.ButtonElement();
    btn.text = "Remove";
    btn.onClick.listen((e) {
      balls.forEach((b) => remove(b));
      balls.clear();
      label.innerHtml = "2 Balls";
    });
    controllers.children.add(btn);
    controllers.children.add(label);

    var cube = new Cube();
    cube.setTranslation(3.0, 1.0, -1.0);
    cube.material = new StandardMaterial();
    cube.receiveShadows = true;
    cube.showBoundingBox = false;
    cube.castShadows = true;
    cube.setPhysicsState(PhysicsEngine.BoxImpostor, new PhysicsBodyCreationOptions(mass: 1.0));
    add(cube);

    //    sphere1.setPhysicsLinkWith(cube, new Vector3(0.0, 1.5, 0.0), new Vector3(0.0, -1.5, 0.0));

    timer = new Timer.periodic(new Duration(seconds: 3), (t) {
      cube.applyImpulse(new Vector3(rnd.nextDouble() * 2, rnd.nextDouble() * 2, rnd.nextDouble() * 2), new Vector3(rnd.nextDouble(), rnd.nextDouble(), rnd.nextDouble()));
      sphere1.applyImpulse(new Vector3(rnd.nextDouble() * 10, rnd.nextDouble() * 10, rnd.nextDouble() * 10), new Vector3(rnd.nextDouble(), rnd.nextDouble(), rnd.nextDouble()));
    });

    var groundMaterial = new StandardMaterial();
    groundMaterial.diffuseColor = new Color.fromList([0.5, 0.5, 0.5]);
    groundMaterial.emissiveColor = new Color.fromList([0.2, 0.2, 0.2]);

    var ground = new PlaneMesh(width: 10, height: 10, ground: true);
    ground.setTranslation(0.0, -2.0, 0.0);
    ground.material = groundMaterial;
    ground.receiveShadows = true;
    ground.castShadows = false;
    ground.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(ground);

    var border = new PlaneMesh(width: 10, height: 10, ground: true);//new Cube(width: 0.5, height: 5, depth: 5);
    border.setTranslation(-5.0, 0.0, 0.0);
    border.rotate(Axis.Z, -PI / 2);
    border.material = groundMaterial;
    border.receiveShadows = true;
    border.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(border);

    var border1 = new PlaneMesh(width: 10, height: 10, ground: true);
    border1.setTranslation(5.0, 0.0, 0.0);
    border1.rotate(Axis.Z, PI / 2);
    border1.material = groundMaterial;
    border1.receiveShadows = true;
    border1.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(border1);

    var border2 = new PlaneMesh(width: 10, height: 10, ground: true);
    border2.setTranslation(0.0, 0.0, -5.0);
    border2.rotate(Axis.X, PI / 2);
    border2.material = groundMaterial;
    border2.receiveShadows = true;
    border2.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(border2);

    var border3 = new PlaneMesh(width: 10, height: 10, ground: true);
    border3.setTranslation(0.0, 0.0, 5.0);
    border3.rotate(Axis.X, -PI / 2);
    border3.material = groundMaterial;
    border3.receiveShadows = true;
    border3.setPhysicsState(PhysicsEngine.PlaneImpostor, new PhysicsBodyCreationOptions(friction: 0.5, restitution: 0.7));
    add(border3);


    var textureManager = new TextureManager();
    textureManager.load(graphicsDevice.ctx, {
      "path": "textures/mosaic.jpg"
    }).then((t) {
      sphereMaterial.diffuseTexture = t;
    });
    textureManager.load(graphicsDevice.ctx, {
      "path": "textures/wood.jpg"
    }).then((t) {
      cube.material.diffuseTexture = t;
    });
    //    textureManager.load(graphicsDevice.ctx, {
    //      "path": "bump.png"
    //    }).then((t) {
    //      //      plane.material.bumpTexture = t;
    //    });

    var light0 = new PointLight(0xffffff);
    light0.intensity = 0.9;
    light0.setTranslation(-5.0, 3.0, 2.0);
    add(light0);

    var light1 = new DirectionalLight(0xffffff);
    light1.intensity = 0.2;
    light1.specular = new Color.fromHex(0xffffff);
    light1.setTranslation(5.0, 3.0, 5.0);
    light1.direction = new Vector3(-1.0, -1.0, 0.0).normalize();
    add(light1);
  }

  @override
  exit() {
    super.exit();
    timer.cancel();
    removeChildren();
    disablePhysics();
  }
}
