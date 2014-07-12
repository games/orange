part of orange_examples;




class TestBabylonWCafeScene extends Scene {
  TestBabylonWCafeScene(Camera camera) : super(camera);

  @override
  void enter() {

    var loader = new BabylonLoader();
    loader.load(graphicsDevice, "models/babylon/WCafe/WCafe.babylon", new BabylonWCafeScene()).then((s) {
      if (s.camera == null) {
        s.camera = camera;
      }
      s.camera = camera;
      engine.enter(s);
    });
  }

}

class BabylonWCafeScene extends Scene {

  @override
  void enter() {
    var boundingInfo = BoundingInfo.compute(nodes);
    var box = boundingInfo.boundingBox;
    var radius = boundingInfo.boundingSphere.radius;
    camera.position = box.center + new Vector3(-radius, radius, radius);
    camera.lookAt(box.center);
  }

  @override
  exit() {
    super.exit();
    removeChildren();
  }

}
