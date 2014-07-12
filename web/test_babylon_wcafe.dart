part of orange_examples;




class TestBabylonWCafeScene extends Scene {
  TestBabylonWCafeScene(Camera camera) : super(camera);

  @override
  void enter() {

    var url = "models/babylon/WCafe/WCafe.babylon";
//    url = "models/babylon/TheCar/TheCar.incremental.babylon";
//    url = "models/babylon/Robot/Robot.babylon";
    var loader = new BabylonLoader();
    loader.load(graphicsDevice, url, new BabylonWCafeScene()).then((s) {
      if (s.camera == null) {
        s.camera = camera;
      } else {
        var controller = camera.controller;
        camera.controller.detach();
        controller.attach(s.camera, controller.element);
      }
//      s.camera = camera;
      engine.enter(s);
    });
  }

}

class BabylonWCafeScene extends Scene {

  @override
  void enter() {
//    var boundingInfo = BoundingInfo.compute(nodes);
//    var box = boundingInfo.boundingBox;
//    var radius = boundingInfo.boundingSphere.radius;
//    camera.position = box.center + new Vector3(-radius, radius, radius);
//    camera.lookAt(box.center);
  }

  @override
  exit() {
    super.exit();
    removeChildren();
  }

}
