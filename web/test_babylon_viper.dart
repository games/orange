part of orange_examples;




class TestBabylonViperScene extends Scene {
  TestBabylonViperScene(Camera camera) : super(camera);

  @override
  void enter() {

    var loader = new BabylonLoader();
    loader.load(graphicsDevice, "models/babylon/Viper/Viper.babylon", new BabylonViperScene()).then((s) {
//      if (s.camera == null) {
//        s.camera = camera;
//      } else {
//        var controller = camera.controller;
//        camera.controller.detach();
//        controller.attach(s.camera, controller.element);
//      }
      s.camera = camera;
      engine.enter(s);
    });
  }

}

class BabylonViperScene extends Scene {

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
